//
//  TariffsViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 13.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class TariffsViewController: UIViewController {

    private let userDefaultsService = UserDefaultsService()
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let cellID = "\(SubtitleCell.self)"
    private let tariffs: [Tariff]
    private let conferenceID: Int
    
    @IBOutlet private weak var noDataLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    init(tariffs: [Tariff], conferenceID: Int) {
        self.tariffs = tariffs
        self.conferenceID = conferenceID
        
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
        navigationItem.title = "Тарифы"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDidTap))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
        
        noDataLabel.isHidden = !tariffs.isEmpty
        tableView.separatorStyle = tariffs.isEmpty ? .none : .singleLine
    }
    
    @objc private func addDidTap() {
        let vc = NewTariffViewController(mode: .new)
        vc.conferenceID = conferenceID
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
}



// MARK: - UITableViewDataSource

extension TariffsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tariffs.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell
        else { return .init(frame: .zero) }
        
        let tariff = tariffs[indexPath.row]
        cell.textLabel?.text = tariff.title
        cell.detailTextLabel?.text = "Цена: \(Int(tariff.price)) y.e., осталось билетов: \(tariff.ticketsLeftCount)"
        return cell
    }
}


// MARK: - UITableViewDelegate

extension TariffsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tariff = tariffs[indexPath.row]
        let vc = NewTariffViewController(mode: .edit(tariff))
        vc.conferenceID = conferenceID
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
}
