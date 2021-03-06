//
//  FavoritesViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class FavoritesViewController: UIViewController {
    
    private let userDefaultsService = UserDefaultsService()
    private let searchController = UISearchController(searchResultsController: nil)
    private let requestSender = RequestSender()
    private let alertService = AlertService()
    private let refreshControl = UIRefreshControl()
    private var events: [[Event]] = []
    private var searchedEvents: [Event] = []
    private let cellID = "\(SubtitleCell.self)"
    private var titles: [String] = []
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет избранного"
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupSearchController()
        setupTableView()
        setupNoDataLabel()
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
        navigationItem.title = "Избранное"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupNoDataLabel() {
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.isHidden = true
        view.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refresh() {
        loadData()
    }
    
    private func loadData() {
        guard let userID = userDefaultsService.getUser()?.id else {
            let alert = self.alertService.alert("Выполните вход под своей учетной записью для просмотра избранных событий")
            self.present(alert, animated: true)
            self.refreshControl.endRefreshing()
            self.spinner.stopAnimating()
            self.noDataLabel.isHidden = false
            self.events = []
            self.searchedEvents = []
            self.tableView.separatorStyle = .none
            self.tableView.reloadData()
            return
        }
        
        let config = RequestFactory.events(userID: userID, limit: 20, offset: 0, areActual: false)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let events):
                self.spinner.stopAnimating()
                self.noDataLabel.isHidden = !events.isEmpty
                self.tableView.separatorStyle = events.isEmpty ? .none : .singleLine
                let groupSorted = events.groupSort(byDate: { $0.dateStart })
                self.events = groupSorted
                self.titles = events.sorted { $0.dateStart > $1.dateStart }.map { $0.dateStartFormatted }
                self.tableView.reloadData()
                
            case .failure:
                self.spinner.stopAnimating()
                self.noDataLabel.isHidden = false
                self.tableView.separatorStyle = .none
            }
        }
    }
    
    private func filterContent(for searchText: String) {
        searchedEvents = events.flatMap { $0 }.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}


// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchController.isActive ? 1 : events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchedEvents.count : events[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !searchController.isActive else { return "Результаты поиска" }
        guard section < titles.count else { return nil }
        return titles[section]
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell
        else { return .init(frame: .zero) }
        
        let event = searchController.isActive ? searchedEvents[indexPath.row] : events[indexPath.section][indexPath.row]
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = event.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = searchController.isActive ? searchedEvents[indexPath.row] : events[indexPath.section][indexPath.row]
        let vc = EventViewController(event: event, isManager: false, fromFavorites: true)
        if let splitVc = splitViewController, !splitVc.isCollapsed {
            (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


// MARK: - UISearchResultsUpdating

extension FavoritesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContent(for: searchText)
        tableView.reloadData()
    }
}


// MARK: - UISplitViewControllerDelegate

extension FavoritesViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
