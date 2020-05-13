//
//  EventsViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 09.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class EventsViewController: UIViewController {

    private let cellID = "\(SubtitleCell.self)"
    private let requestSender = RequestSender()
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    
    private let events: [Event]
    private let username: String
    
    init(events: [Event], username: String) {
        self.events = events
        self.username = username
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupTableView()
    }

    private func setupNavigation() {
        navigationItem.title = username
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
}


// MARK: - UITableViewDataSource

extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell
            else { return .init(frame: .zero) }
        
        let event = events[indexPath.row]
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = event.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
}


// MARK: - UITableViewDelegate

extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.section]
        let vc = EventViewController(event: event, isManager: false, isFavorite: nil)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
