//
//  PurchaseViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 01.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class PurchaseViewController: UIViewController {

    private let userDefaultsService = UserDefaultsService()
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let cellID = "\(SubtitleCell.self)"
    private let tariffs: [Tariff]
    
    @IBOutlet private weak var tableView: UITableView!
    
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
        navigationItem.title = "Покупка билета"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}



// MARK: - UITableViewDataSource

extension PurchaseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tariffs.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SubtitleCell else { return .init(frame: .zero) }
        let tariff = tariffs[indexPath.row]
        cell.textLabel?.text = tariff.title
        cell.detailTextLabel?.text = "Цена: \(tariff.price) ₽, осталось билетов: \(tariff.ticketsLeftCount)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension PurchaseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let tariff = tariffs[indexPath.row]
        guard let id = tariff.id, let user = userDefaultsService.getUser() else { return }
        let ticket = Ticket(id: nil, released: Date(), tariffID: id, buyerID: user.id)
        let config = RequestFactory.registerTicket(ticket)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                guard message.success else {
                    let alert = self.alertService.alert(message.message)
                    self.present(alert, animated: true)
                    return
                }
                
                self.userDefaultsService.appendTicketId(message.message)
                let alert = self.alertService.alert("Вы успешно приобрели билет!", title: .info)
                self.present(alert, animated: true)
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
