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
    
    private let conference: Conference
    private let ticket: Ticket
    
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
        
        titleLabel.text = conference.title
        dateStartLabel.text = dateStart
        dateEndLabel.text = dateEnd
        descriptionLabel.text = conference.description
        tariffLabel.text = conference.tariffs?.first { $0.id == ticket.tariffID }?.title
        datePurchaseLabel.text = datePurchase
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
               let vc = ScheduleViewController(parentID: id)
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
        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printController.printInfo = printInfo
        
        let formatter = UIMarkupTextPrintFormatter(markupText: "<h1>Test</h1>")
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter
        
        printController.present(animated: true, completionHandler: nil)
    }
    
    @objc private func passButtonDidTap() {
        
    }
}
