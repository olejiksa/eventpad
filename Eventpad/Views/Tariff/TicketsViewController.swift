//
//  TicketsViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class TicketsViewController: UIViewController {
    
    private let userDefaultsService = UserDefaultsService()
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let cellID = "\(SubtitleCell.self)"
    private let refreshControl = UIRefreshControl()
    private var tickets: [String: String] = [:]
    private var conferences: [Conference] = []
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupRefreshControl()
        loadData()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Билеты"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
        
        guard let tickets = userDefaultsService.getTicketIDs() else { return }
        self.tickets = tickets
    }
    
    private func loadData() {
        guard let user = userDefaultsService.getUser() else { return }
        let config = RequestFactory.conferences(userID: user.id, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let conferences):
                self.conferences = conferences
                self.tableView.separatorStyle = .singleLine
                self.noDataLabel.isHidden = true
                self.tableView.reloadData()
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refresh() {
        loadData()
    }
}


// MARK: - UITableViewDataSource

extension TicketsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return conferences.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell else { return .init(frame: .zero) }
        
        let conference = conferences[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateStart)!
        let dateStart = dateFormatter.string(from: dateStartFinal)
        
        cell.textLabel?.text = conference.title
        cell.detailTextLabel?.text = dateStart
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension TicketsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let conference = conferences[indexPath.row]
        guard let ticket = tickets[String(conference.id!)] else { return }
        let config = RequestFactory.ticket(ticketID: ticket)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let ticket):
                let vc = TicketViewController(conference: conference, ticket: ticket)
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
