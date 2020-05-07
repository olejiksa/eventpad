//
//  EventViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 05.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import EventKit
import UIKit

final class EventViewController: UIViewController {

    private let store = EKEventStore()
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    private let event: Event
    private let isManager: Bool

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateStartLabel: UILabel!
    @IBOutlet private weak var dateEndLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    init(event: Event, isManager: Bool) {
        self.event = event
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
        navigationItem.title = "Событие"
        navigationItem.largeTitleDisplayMode = .never
        
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        let shareButton = UIBarButtonItem(image: shareImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(shareDidTap))
        
        let favoriteImage = UIImage(systemName: "star")
        let favoriteButton = UIBarButtonItem(image: favoriteImage,
                                             style: .plain,
                                             target: self,
                                             action: #selector(starDidTap))
        navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
    }
    
    private func setupView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: event.dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: event.dateEnd)!
        
        let dateStart = dateFormatter.string(from: dateStartFinal)
        let dateEnd = dateFormatter.string(from: dateEndFinal)
        
        titleLabel.text = event.title
        dateStartLabel.text = dateStart
        dateEndLabel.text = dateEnd
        descriptionLabel.text = event.description
    }
    
    @objc private func shareDidTap() {
        guard let id = event.id else { return }
        let text = event.title
        let url = URL(string: "eventpad://event?id=\(id)")!
        let sharedObjects = [url as AnyObject, text as AnyObject]
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func starDidTap() {
        guard let id = event.id, let userID = userDefaultsService.getUser()?.id else { return }
        let config = RequestFactory.favoriteEvent(eventID: id, userID: userID)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
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
    
    @IBAction private func calendarDidTap() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: event.dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: event.dateEnd)!
        
        createEventInTheCalendar(with: event.title,
                                 forDate: dateStartFinal,
                                 toDate: dateEndFinal)
    }
    
    @IBAction private func remindersDidTap() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: event.dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: event.dateEnd)!
        
        createEventInTheReminders(with: event.title,
                                  forDate: dateStartFinal,
                                  toDate: dateEndFinal)
    }
    
    @IBAction private func scheduleDidTap() {
        guard let id = event.id else { return }
        let vc = ScheduleViewController(parentID: id)
        navigationController?.pushViewController(vc, animated: true)
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
            event.notes = self.event.description
            
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
                reminder.notes = self.event.description
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
        guard let userID = event.speakerID else { return }
        let config = RequestFactory.user(userID: userID, role: .participant)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                let vc = AccountViewController(user: user, isNotMine: true)
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
                break
            }
        }
    }
}