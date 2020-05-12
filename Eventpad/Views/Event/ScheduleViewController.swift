//
//  ScheduleViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 05.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class ScheduleViewController: UIViewController {

    private let cellID = "\(SubtitleCell.self)"
    private let titles = ["6 May", "5 May"]
    private var items: [[Event]] = []
    
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let parentID: Int

    init(parentID: Int) {
        self.parentID = parentID
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupTableView()
        
        loadData()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Расписание"
    }
    
    private func setupTableView() {
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func loadData() {
        let config = RequestFactory.events(conferenceID: parentID, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let events):
                self.items = [events]
                self.tableView.reloadData()
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section][indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: item.dateStart)!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .medium
        let dateString = dateformatter.string(from: dateStartFinal)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = dateString
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let event = items[indexPath.section][indexPath.row]
        let vc = EventViewController(event: event, isManager: false)
        navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
