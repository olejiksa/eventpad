//
//  FavoritesViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class FavoritesViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    private let items: [(String, String)] = []
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
        setupNoDataLabel()
        setupRefreshControl()
        
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func setupNavigation() {
        navigationItem.title = "Избранное"
        navigationController?.navigationBar.prefersLargeTitles = true
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
        refreshControl.endRefreshing()
    }
}


// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell
        else { return .init(frame: .zero) }
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.0
        cell.detailTextLabel?.text = item.1
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
