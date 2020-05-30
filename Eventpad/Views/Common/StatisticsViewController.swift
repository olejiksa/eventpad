//
//  StatisticsViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 11.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class StatisticsViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!

    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let cellID = "\(StatisticsCell.self)"
    private var conferences: [Conference] = []
    private let username: String
    private let refreshControl = UIRefreshControl()
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    init(username: String) {
        self.username = username
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupTableView()
        setupRefreshControl()
        setupSpinner()
        loadData()
    }

    private func setupNavigation() {
        navigationItem.title = "Статистика"
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func loadData() {
        let config = RequestFactory.conferences(username: username, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()

            switch result {
            case .success(let conferences):
                self.conferences = conferences
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                
                if conferences.isEmpty {
                    self.tableView.separatorStyle = .none
                    self.noDataLabel.isHidden = false
                } else {
                    self.tableView.separatorStyle = .singleLine
                    self.noDataLabel.isHidden = true
                }
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func refresh() {
        loadData()
    }
    
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}


// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return conferences.isEmpty ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Число регистраций" : "Продано билетов"
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return conferences.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                       for: indexPath) as? StatisticsCell else { return .init(frame: .zero) }
        
        switch indexPath.section {
        case 0:
            let conference = conferences[indexPath.row]
            cell.titleLabel?.text = conference.title
            let ticketsLeft = conference.tariffs?.reduce(into: 0, { sum, item in
                sum = item.price == 0 ? sum + item.ticketsLeftCount : sum
            }) ?? 0
            let ticketsTotal = conference.tariffs?.reduce(into: 0, { sum, item in
                sum = item.price == 0 ? sum + item.ticketsTotalCount : sum
            }) ?? 0
            let ticketsSold = ticketsTotal - ticketsLeft
            if ticketsTotal > 0 {
                cell.progressView.progress = Float(ticketsSold) / Float(ticketsTotal)
                cell.statLabel.text = "\(ticketsSold)/\(ticketsTotal)"
            } else {
                cell.progressView.progress = 0
                cell.statLabel.text = "Нет бесплатных тарифов"
            }
            return cell
            
        case 1:
            let conference = conferences[indexPath.row]
            cell.titleLabel?.text = conference.title
            let ticketsLeft = conference.tariffs?.reduce(into: 0, { sum, item in
                sum = item.price > 0 ? sum + item.ticketsLeftCount : sum
            }) ?? 0
            let ticketsTotal = conference.tariffs?.reduce(into: 0, { sum, item in
                sum = item.price > 0 ? sum + item.ticketsTotalCount : sum
            }) ?? 0
            let ticketsSold = ticketsTotal - ticketsLeft
            if ticketsTotal > 0 {
                cell.progressView.progress = Float(ticketsSold) / Float(ticketsTotal)
                cell.statLabel.text = "\(ticketsSold)/\(ticketsTotal)"
            } else {
                cell.progressView.progress = 0
                cell.statLabel.text = "Нет платных тарифов"
            }
            return cell
            
        default:
            return .init(frame: .zero)
        }
    }
}


// MARK: - UITableViewDelegate

extension StatisticsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conference = conferences[indexPath.row]
        guard let tariffs = conference.tariffs, !tariffs.isEmpty else { return }
        if indexPath.section == 0 {
            guard tariffs.first(where: { $0.price == 0 }) != nil else { return }
            let vc = TariffDataViewController(tariffs: tariffs, free: true)
            if let splitVc = splitViewController, !splitVc.isCollapsed {
                (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            guard tariffs.first(where: { $0.price > 0 }) != nil else { return }
            let vc = TariffDataViewController(tariffs: tariffs, free: false)
            if let splitVc = splitViewController, !splitVc.isCollapsed {
                (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
