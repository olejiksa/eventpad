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
    private var titles: [String] = []
    private var items: [[Event]] = []
    
    @IBOutlet private weak var noDataLabel: UILabel!
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let parentID: Int
    private let isManager: Bool

    init(parentID: Int, isManager: Bool) {
        self.parentID = parentID
        self.isManager = isManager
        
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
        
        if isManager {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(addDidTap))
            navigationItem.rightBarButtonItem = addButton
        }
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
                self.noDataLabel.isHidden = !events.isEmpty
                self.tableView.separatorStyle = events.isEmpty ? .none : .singleLine
                let groupSorted = events.groupSort(byDate: { $0.dateStart })
                self.items = groupSorted
                self.titles = events.sorted { $0.dateStart > $1.dateStart }.map { $0.dateStartFormatted }
                self.tableView.reloadData()
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func addDidTap() {
        let vc = NewEventViewController(conferenceID: parentID)
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
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
        guard section < titles.count else { return nil }
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
        let vc = EventViewController(event: event, isManager: isManager, isFavorite: nil)
        navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension Sequence {
    
    func groupSort(ascending: Bool = false,
                   byDate dateKey: (Iterator.Element) -> Date) -> [[Iterator.Element]] {
        var categories: [[Iterator.Element]] = []
        for element in self {
            let key = dateKey(element)
            guard let dayIndex = categories.firstIndex(where: { $0.contains(where: { Calendar.current.isDate(dateKey($0), inSameDayAs: key) }) }) else {
                guard let nextIndex = categories.firstIndex(where: { $0.contains(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) }) else {
                    categories.append([element])
                    continue
                }
                categories.insert([element], at: nextIndex)
                continue
            }

            guard let nextIndex = categories[dayIndex].firstIndex(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) else {
                categories[dayIndex].append(element)
                continue
            }
            categories[dayIndex].insert(element, at: nextIndex)
        }
        return categories
    }
}
