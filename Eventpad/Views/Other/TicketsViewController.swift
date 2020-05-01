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
    private var tickets: [Ticket] = []
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupRefreshControl()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Билеты"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func loadData() {
        guard let ticketIDs = userDefaultsService.getTicketIDs(), let first = ticketIDs.first else {
            self.refreshControl.endRefreshing()
            return }
        let config = RequestFactory.ticket(ticketID: first)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let ticket):
                self.tickets = [ticket]
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
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell else { return .init(frame: .zero) }
            
        let ticket = tickets[indexPath.row]
        cell.textLabel?.text = ticket.released.description
        cell.detailTextLabel?.text = ticket.tariffID.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension TicketsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
