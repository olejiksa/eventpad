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
    
    private var selectedScope: Int = 0
    private var conferences: [Conference] = []
    private var events: [Event] = []
    private var users: [User] = []
    private var speakers: [User] = []
    
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
        searchController.searchBar.placeholder = "Конференции, события, пользователи, спикеры"
        searchController.searchBar.scopeButtonTitles = ["Конференции",
                                                        "События",
                                                        "Пользователи",
                                                        "Спикеры"]
        
        navigationItem.searchController = searchController
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
}


// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // guard let searchText = searchController.searchBar.text else { return }
        // filterContent(for: searchText)
        // tableView.reloadData()
    }
}


// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.selectedScope = selectedScope
    }
}


// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedScope {
        case 0:
            return conferences.count
        
        case 1:
            return events.count
            
        case 2:
            return users.count
            
        case 3:
            return speakers.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell
        else { return .init(frame: .zero) }
        
        switch selectedScope {
        case 0:
            let conference = conferences[indexPath.row]
            cell.textLabel?.text = conference.title
            cell.detailTextLabel?.text = conference.description
        
        case 1:
            let event = events[indexPath.row]
            cell.textLabel?.text = event.title
            cell.detailTextLabel?.text = event.description
            
        case 2:
            let user = users[indexPath.row]
            cell.textLabel?.text = user.username
            cell.detailTextLabel?.text = "\(user.name) \(user.surname)"
            
        case 3:
            let speaker = speakers[indexPath.row]
            cell.textLabel?.text = speaker.username
            cell.detailTextLabel?.text = "\(speaker.name) \(speaker.surname)"
            
        default:
            break
        }
        
        return cell
    }
}


// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
