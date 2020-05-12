//
//  TariffDataViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 12.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class TariffDataViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private let cellID = "\(StatisticsCell.self)"
    private let tariffs: [Tariff]
    
    init(tariffs: [Tariff]) {
        self.tariffs = tariffs
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupTableView()
    }

    private func setupNavigation() {
        navigationItem.title = "Статистика по тарифам"
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
    }
}


// MARK: - UITableViewDataSource

extension TariffDataViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tariffs.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                       for: indexPath) as? StatisticsCell else { return .init(frame: .zero) }
        let tariff = tariffs[indexPath.row]
        cell.titleLabel?.text = tariff.title
        let ticketsLeft = tariff.ticketsLeftCount
        let ticketsTotal = tariff.ticketsTotalCount
        let ticketsSold = ticketsTotal - ticketsLeft
        cell.statLabel.text = "\(ticketsSold)/\(ticketsTotal)"
        cell.progressView.progress = Float(ticketsSold) / Float(ticketsTotal)
        return cell
    }
}


// MARK: - UITableViewDelegate

extension TariffDataViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
