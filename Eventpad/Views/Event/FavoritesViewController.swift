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
    private let requestSender = RequestSender()
    private let alertService = AlertService()
    private let refreshControl = UIRefreshControl()
    private var events: [Event] = []
    private let cellID = "\(SubtitleCell.self)"
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
        setupTableView()
        setupNoDataLabel()
        setupRefreshControl()
        loadData()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Избранное"
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func setupNoDataLabel() {
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
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
        guard let userID = userDefaultsService.getUser()?.id else { return }
        let config = RequestFactory.events(userID: userID, limit: 20, offset: 0, areActual: false)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let events):
                self.events = events
                self.noDataLabel.isHidden = !events.isEmpty
                self.tableView.separatorStyle = events.isEmpty ? .none : .singleLine
                self.tableView.reloadData()
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell
        else { return .init(frame: .zero) }
        
        let item = events[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = events[indexPath.row]
        let vc = EventViewController(event: event, isManager: false, isFavorite: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
