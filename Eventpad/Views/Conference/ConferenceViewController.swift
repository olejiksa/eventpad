//
//  ConferenceViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 02.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import MapKit
import UIKit
import EventKit

final class ConferenceViewController: UIViewController {
    
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let userDefaultsService = UserDefaultsService()
    private let conference: Conference
    private let store = EKEventStore()
    private let isManager: Bool
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateStartLabel: UILabel!
    @IBOutlet private weak var dateEndLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    
    @IBOutlet private weak var contactButton: BigButton!
    @IBOutlet private weak var registerButton: BigButton!
    @IBOutlet private weak var scheduleButton: BigButton!
    @IBOutlet private weak var pushButton: BigButton!
    @IBOutlet private weak var deleteButton: BigButton!
    @IBOutlet private weak var tariffsButton: BigButton!
    
    init(conference: Conference, isManager: Bool) {
        self.conference = conference
        self.isManager = isManager
        
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
        navigationItem.title = "Конференция"
        navigationItem.largeTitleDisplayMode = .never
        
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        let shareButton = UIBarButtonItem(image: shareImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(shareDidTap))

        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(didEditTap))
        
        if !isManager {
            navigationItem.rightBarButtonItems = [shareButton]
        } else {
            navigationItem.rightBarButtonItems = [shareButton, editButton]
        }
    }
    
    @objc private func didEditTap() {
        let vc = NewConferenceViewController(mode: .edit(conference))
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
    
    private func setupView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let dateStart = dateFormatter.string(from: conference.dateStart)
        let dateEnd = dateFormatter.string(from: conference.dateEnd)
        
        titleLabel.text = conference.title
        dateStartLabel.text = dateStart
        dateEndLabel.text = dateEnd
        descriptionLabel.text = conference.description.isEmpty ? "(отсутствует)" : conference.description
        categoryLabel.text = conference.category.description
        locationLabel.text = conference.location
        
        if let url = conference.photoUrl, let image = convertBase64ToImage(url) {
            imageView.image = image
        }
        
        contactButton.isHidden = isManager || Global.role == .organizer
        registerButton.isHidden = isManager || conference.tariffs!.isEmpty || Global.role == .organizer
        tariffsButton.isHidden = !isManager
        pushButton.isHidden = true
        deleteButton.isHidden = !isManager
    }
    
    @IBAction private func registerDidTap() {
        if Global.accessToken == nil {
            let vc = AuthViewController()
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .formSheet
            present(nvc, animated: true)
        } else if let tariffs = conference.tariffs {
            let vc = PurchaseViewController(tariffs: tariffs, conferenceID: conference.id!)
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .formSheet
            present(nvc, animated: true)
        }
    }
    
    @IBAction private func openMapDidTap() {
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
    
    @objc private func shareDidTap(sender: UIBarButtonItem) {
        guard let id = conference.id else { return }
        let text = conference.title
        let url = URL(string: "eventpad://conference?id=\(id)")!
        let sharedObjects = [url as AnyObject, text as AnyObject]
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityViewController.popoverPresentationController?.barButtonItem = sender
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction private func didCalendarTap() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        createEventInTheCalendar(with: conference.title,
                                 forDate: conference.dateStart,
                                 toDate: conference.dateEnd)
    }
    
    @IBAction private func didRemindersTap() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        createEventInTheReminders(with: conference.title,
                                  forDate: conference.dateStart,
                                  toDate: conference.dateEnd)
    }
    
    @IBAction private func scheduleDidTap() {
        guard let id = conference.id else { return }
        let vc = ScheduleViewController(parentID: id, isManager: isManager)
        if let splitVc = splitViewController, !splitVc.isCollapsed {
            (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction private func contactDidTap() {
        guard let userID = conference.organizerID else { return }
        contactButton.showLoading()
        let config = RequestFactory.user(userID: userID, role: .organizer)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.contactButton.hideLoading()
            
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
    
    @IBAction private func pushDidTap() {
        guard let id = conference.id else { return }
        pushButton.showLoading()
        let pushNotification = PushNotification(title: "Test", text: "Test message")
        let config = RequestFactory.sendPushNotification(conferenceID: id, pushNotification: pushNotification)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.pushButton.hideLoading()
            
            switch result {
            case .success(let success):
                guard success.success else {
                    let alert = self.alertService.alert(success.message!)
                    self.present(alert, animated: true)
                    return
                }
                
                let alert = self.alertService.alert(success.success.description, title: .info)
                self.present(alert, animated: true)
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction private func deleteDidTap() {
        deleteButton.showLoading()
        let config = RequestFactory.deleteConference(conferenceID: conference.id!)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.deleteButton.hideLoading()
            
            switch result {
            case .success(let success):
                guard success.success else {
                    let alert = self.alertService.alert(success.message!)
                    self.present(alert, animated: true)
                    return
                }
                
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction private func tariffsDidTap(_ sender: Any) {
        let vc = TariffsViewController(tariffs: conference.tariffs!, conferenceID: conference.id!)
        navigationController?.pushViewController(vc, animated: true)
    }
}
