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
    private let searchController = UISearchController(searchResultsController: nil)
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let cellID = "\(SubtitleCell.self)"
    private let refreshControl = UIRefreshControl()
    private var tickets: [String: String] = [:]
    private var conferences: [Conference] = []
    private var searchedConferences: [Conference] = []
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupSearchController()
        setupRefreshControl()
        setupSpinner()
        loadData()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func setupNavigation() {
        navigationItem.title = "Билеты"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
        
        guard let tickets = userDefaultsService.getTicketIDs() else { return }
        self.tickets = tickets
    }
    
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func loadData() {
        guard let user = userDefaultsService.getUser() else {
            let alert = self.alertService.alert("Выполните вход под своей учетной записью для просмотра билетов")
            self.present(alert, animated: true)
            self.refreshControl.endRefreshing()
            self.spinner.stopAnimating()
            self.noDataLabel.isHidden = false
            self.conferences = []
            self.searchedConferences = []
            self.tableView.separatorStyle = .none
            self.tableView.reloadData()
            return
        }
        
        let config = RequestFactory.conferences(userID: user.id!, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let conferences):
                self.conferences = Array(Set(conferences)).sorted(by: { $0.dateStart > $1.dateStart })
                self.tableView.separatorStyle = .singleLine
                self.noDataLabel.isHidden = !conferences.isEmpty
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                
            case .failure:
                self.spinner.stopAnimating()
                self.noDataLabel.isHidden = false
                self.tableView.separatorStyle = .none
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
    
    private func searchTicket(i: Int = 0,
                              conference: Conference,
                              completion: @escaping ((Ticket) -> ())) {
        guard let user = userDefaultsService.getUser() else { return }
        let config = RequestFactory.ticket(ticketID: String(i))
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let ticket):
                guard let tariffs = conference.tariffs else { return }
                if tariffs.contains(where: { $0.id == ticket.tariffID && ticket.buyerID == user.id }) {
                    completion(ticket)
                } else {
                    self.searchTicket(i: i + 1,
                                      conference: conference,
                                      completion: completion)
                }
                
            case .failure:
                self.searchTicket(i: i + 1,
                                  conference: conference,
                                  completion: completion)
            }
        }
    }
    
    private func getTicket(ticketID: String, conference: Conference) {
        let config = RequestFactory.ticket(ticketID: ticketID)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let ticket):
                self.dismiss(animated: false, completion: nil)
                let vc = TicketViewController(conference: conference, ticket: ticket)
                if let splitVc = self.splitViewController, !splitVc.isCollapsed {
                    (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
                } else {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    private func filterContent(for searchText: String) {
        searchedConferences = conferences.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}


// MARK: - UITableViewDataSource

extension TicketsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchedConferences.count : conferences.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                       for: indexPath) as? SubtitleCell else { return .init(frame: .zero) }
        
        let conference = searchController.isActive ? searchedConferences[indexPath.row] : conferences[indexPath.row]
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .short
//
//        var dateComponent = DateComponents()
//        dateComponent.year = 31
//        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: conference.dateStart)!
//        let dateStart = dateFormatter.string(from: dateStartFinal)
        
        cell.textLabel?.text = conference.title
        cell.detailTextLabel?.text = conference.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension TicketsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conference = searchController.isActive ? searchedConferences[indexPath.row] : conferences[indexPath.row]
        let ticket = tickets[String(conference.id!)]
        if ticket == nil {
            let alert = UIAlertController(title: nil, message: "Идет загрузка...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating()

            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            searchTicket(conference: conference) { [weak self] ticket in
                self?.getTicket(ticketID: String(ticket.id!), conference: conference)
            }
        } else {
            getTicket(ticketID: ticket!, conference: conference)
        }
    }
}


// MARK: - UISearchResultsUpdating

extension TicketsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContent(for: searchText)
        tableView.reloadData()
    }
}


// MARK: - UISplitViewControllerDelegate

extension TicketsViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
