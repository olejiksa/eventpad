//
//  SearchViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class SearchViewController: UIViewController {

    private let cellID = "\(SubtitleCell.self)"
    private let searchController = UISearchController(searchResultsController: nil)
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    
    private var searchItemType: SearchItemType = .conference
    private var conferences: [Conference] = []
    private var events: [Event] = []
    private var users: [User] = []
    
    @IBOutlet private weak var tableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupSearchController()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
        
       searchController.searchBar.becomeFirstResponder()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Поиск"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Конференции, события, пользователи"
        searchController.searchBar.scopeButtonTitles = ["Конференции",
                                                        "События",
                                                        "Пользователи"]
        
        navigationItem.searchController = searchController
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func loadData(for searchText: String) {
        switch searchItemType {
        case .conference:
            loadConferences(for: searchText)
        
        case .event:
            loadEvents(for: searchText)
            
        case .user:
            loadUsers(for: searchText)
        }
    }
    
    private func loadConferences(for searchText: String) {
        let config = RequestFactory.conferences(text: searchText, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let conferences):
                self.conferences = conferences
                self.tableView.reloadData()
        
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    private func loadEvents(for searchText: String) {
        let config = RequestFactory.events(text: searchText, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
        
            switch result {
            case .success(let events):
                self.events = events
                self.tableView.reloadData()
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    private func loadUsers(for searchText: String) {
        let config = RequestFactory.users(text: searchText, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
        
            switch result {
            case .success(let users):
                self.users = users
                self.tableView.reloadData()
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
}


// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            self.users = []
            self.events = []
            self.conferences = []
            tableView.reloadData()
            tableView.isHidden = true
            return
        }
        
        tableView.isHidden = false
        loadData(for: searchText)
    }
}


// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchItemType = SearchItemType(rawValue: selectedScope) ?? .conference
    }
}


// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchItemType {
        case .conference:
            return conferences.count
        
        case .event:
            return events.count
            
        case .user:
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell
        else { return .init(frame: .zero) }
        
        switch searchItemType {
        case .conference:
            let conference = conferences[indexPath.row]
            cell.textLabel?.text = conference.title
            cell.detailTextLabel?.text = conference.description
        
        case .event:
            let event = events[indexPath.row]
            cell.textLabel?.text = event.title
            cell.detailTextLabel?.text = event.description
            
        case .user:
            let user = users[indexPath.row]
            cell.textLabel?.text = user.username
            cell.detailTextLabel?.text = "\(user.name) \(user.surname)"
        }
        
        return cell
    }
}


// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchItemType {
        case .conference:
            let conference = conferences[indexPath.row]
            let vc = ConferenceViewController(conference: conference, isManager: false)
            navigationController?.pushViewController(vc, animated: true)
        
        case .event:
            let event = events[indexPath.row]
            let vc = EventViewController(event: event, isManager: false)
            navigationController?.pushViewController(vc, animated: true)
            
        case .user:
            let user = users[indexPath.row]
            let vc = AccountViewController(user: user, isNotMine: true)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
