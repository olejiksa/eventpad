//
//  TicketViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 08.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import EventKit
import MapKit
import PassKit
import UIKit

final class TicketViewController: UIViewController {

    private let store = EKEventStore()
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    
    @IBOutlet private weak var photoView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateEndLabel: UILabel!
    @IBOutlet private weak var dateStartLabel: UILabel!
    @IBOutlet private weak var calendarButton: BigButton!
    @IBOutlet private weak var reminderButton: BigButton!
    @IBOutlet private weak var scheduleButton: BigButton!
    @IBOutlet private weak var mapButton: BigButton!
    @IBOutlet private weak var contactButton: BigButton!
    @IBOutlet private weak var bottomStackView: UIStackView!
    @IBOutlet private weak var tariffLabel: UILabel!
    @IBOutlet private weak var datePurchaseLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    
    private let conference: Conference
    private let ticket: Ticket
    
    var isDarkMode: Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }
    
    init(conference: Conference, ticket: Ticket) {
        self.conference = conference
        self.ticket = ticket
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupView()
        imageView.image = generateQR(isDarkMode: isDarkMode)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        imageView.image = generateQR(isDarkMode: isDarkMode)
    }
    
    private func setupNavigation() {
        navigationItem.title = "Билет"
        navigationItem.largeTitleDisplayMode = .never
        
        let printImage = UIImage(systemName: "printer")
        let printButton = UIBarButtonItem(image: printImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(printDidTap))
        navigationItem.rightBarButtonItem = printButton
    }
    
    private func setupView() {
        let passButton = PKAddPassButton(addPassButtonStyle: .blackOutline)
        passButton.addTarget(self, action: #selector(passButtonDidTap), for: .touchUpInside)
        bottomStackView.addArrangedSubview(passButton)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateEnd)!
        
        let dateStart = dateFormatter.string(from: dateStartFinal)
        let dateEnd = dateFormatter.string(from: dateEndFinal)
        let datePurchase = dateFormatter.string(from: ticket.released)
        
        if let url = conference.photoUrl {
            let url = URL(string: url)
            photoView.kf.setImage(with: url)
        }
        
        titleLabel.text = conference.title
        dateStartLabel.text = dateStart
        dateEndLabel.text = dateEnd
        descriptionLabel.text = conference.description
        tariffLabel.text = conference.tariffs?.first { $0.id == ticket.tariffID }?.title
        datePurchaseLabel.text = datePurchase
        categoryLabel.text = conference.category.description
        locationLabel.text = conference.location
    }
    
    @IBAction func calendarDidTap() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateEnd)!
        
        createEventInTheCalendar(with: conference.title,
                                 forDate: dateStartFinal,
                                 toDate: dateEndFinal)
    }
    
    @IBAction func reminderDidTap() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateEnd)!
        
        createEventInTheReminders(with: conference.title,
                                  forDate: dateStartFinal,
                                  toDate: dateEndFinal)
    }
    
    @IBAction func scheduleDidTap() {
        guard let id = conference.id else { return }
        let vc = ScheduleViewController(parentID: id, isManager: false)
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func mapDidTap() {
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(55.4524, 37.3851)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = conference.title
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func contactDidTap() {
        guard let userID = conference.organizerID else { return }
        let config = RequestFactory.user(userID: userID, role: .organizer)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                let vc = AccountViewController(user: user, role: .organizer, isNotMine: true)
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    private func createEventInTheCalendar(with title: String,
                                          forDate eventStartDate: Date,
                                          toDate eventEndDate: Date) {
        store.requestAccess(to: .event) { [weak self] success, error in
            guard let self = self else { return }
            
            guard error == nil else {
                print("error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            let event = EKEvent(eventStore: self.store)
            event.title = title
            event.calendar = self.store.defaultCalendarForNewEvents
            event.startDate = eventStartDate
            event.endDate = eventEndDate
            event.notes = self.conference.description
            
            let alarm = EKAlarm(absoluteDate: Date(timeInterval: -3600, since: event.startDate))
            event.addAlarm(alarm)
            
            do {
                try self.store.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    let alert = self.alertService.alert("Событие добавлено в Calendar", title: .info)
                    self.present(alert, animated: true)
                }
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    private func createEventInTheReminders(with title: String,
                                           forDate eventStartDate: Date,
                                           toDate eventEndDate: Date?) {
        store.requestAccess(to: EKEntityType.reminder, completion: { [weak self] granted, error in
            guard let self = self else { return }
            
            if granted && error == nil {
                print("granted \(granted)")
                
                let reminder: EKReminder = EKReminder(eventStore: self.store)
                reminder.title = title
                
                let alarmTime = eventStartDate
                let alarm = EKAlarm(absoluteDate: alarmTime)
                reminder.addAlarm(alarm)
                reminder.notes = self.conference.description
                reminder.calendar = self.store.defaultCalendarForNewReminders()
                
                do {
                    try self.store.save(reminder, commit: true)
                    DispatchQueue.main.async {
                        let alert = self.alertService.alert("Событие добавлено в Reminders", title: .info)
                        self.present(alert, animated: true)
                    }
                } catch {
                    print("Cannot save")
                    return
                }
                
                print("Reminder saved")
            }
        })
    }
    
    @objc private func printDidTap() {
        guard let userID = conference.organizerID else { return }
        let config = RequestFactory.user(userID: userID, role: .organizer)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.printTicket(user)
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    private func printTicket(_ user: User) {
        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printController.printInfo = printInfo
        
        let image = generateQR(isDarkMode: false)
        let imageData = image!.pngData() ?? nil
        let base64String = imageData?.base64EncodedString() ?? ""
        var htmlString = ""
        htmlString += "<h2>\(conference.title)</h2>"
        htmlString += "<img src='data:image/png;base64,\(String(describing: base64String))'>"
        htmlString += "<p>\(conference.description)<p>"
        htmlString += "<p><b>Категория</b>: \(conference.category)<p>"
        htmlString += "<p><b>Дата и время начала</b>: \(dateStartLabel.text!)</p>"
        htmlString += "<p><b>Дата и время окончания</b>: \(dateEndLabel.text!)</p>"
        htmlString += "<p><b>Местоположение</b>: \(conference.location)</p>"
        htmlString += "<p><b>Дата и время покупки</b>: \(datePurchaseLabel.text!)</p>"
        htmlString += "<p><b>Тариф</b>: \(tariffLabel.text ?? "")</p>"
        htmlString += "<h4>Контакты организатора</h4>"
        htmlString += "<p><b>Имя и фамилия</b>: \(user.name) \(user.surname)</p>"
        htmlString += "<p><b>Телефон</b>: \(user.phone ?? "отсутствует")</p>"
        htmlString += "<p><b>Адрес электронной почты</b>: \(user.email ?? "отсутствует")</p>"

        let formatter = UIMarkupTextPrintFormatter(markupText: htmlString)
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter
        
        printController.present(animated: true, completionHandler: nil)
    }
    
    @objc private func passButtonDidTap() {
        
    }
    
    private func generateQR(isDarkMode: Bool) -> UIImage? {
        if isDarkMode {
            let string = "eventpad://ticket?id=\(ticket.id!)"
            let data = string.data(using: String.Encoding.ascii)
            guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
            qrFilter.setValue(data, forKey: "inputMessage")
            guard let qrImage = qrFilter.outputImage else { return nil }
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledQrImage = qrImage.transformed(by: transform)
            guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return nil }
            colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
            guard let outputInvertedImage = colorInvertFilter.outputImage else { return nil }
            guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
            maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
            guard let outputCIImage = maskToAlphaFilter.outputImage else { return nil }
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
            return UIImage(cgImage: cgImage)
        } else {
            let string = "eventpad://ticket?id=\(ticket.id!)"
            let data = string.data(using: String.Encoding.ascii)
            guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
            qrFilter.setValue(data, forKey: "inputMessage")
            guard let qrImage = qrFilter.outputImage else { return nil }
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledQrImage = qrImage.transformed(by: transform)
            let context = CIContext()
            guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil }
            return UIImage(cgImage: cgImage)
        }
    }
}
