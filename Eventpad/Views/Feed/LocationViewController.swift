//
//  LocationViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class LocationViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var showAllSwitch: UISwitch!
    
    private var items = ["Москва", "Санкт-Петербург"]
    private let cellID = "\(UITableViewCell.self)"
    private var lastSelectedIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupIndex()
    }
    
    private func setupNavigation() {
        navigationItem.title = "По местоположению"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.isHidden = Global.location == nil
        showAllSwitch.isOn = Global.location == nil
    }

    @objc private func close() {
        dismiss(animated: true)
    }
    
    @IBAction private func showAllSwitchDidValueChange() {
        tableView.isHidden = showAllSwitch.isOn
        if showAllSwitch.isOn {
            Global.location = nil
            lastSelectedIndexPath = nil
        } else {
            lastSelectedIndexPath = IndexPath(row: 0, section: 0)
            Global.location = "Москва"
        }
    }
    
    private func setupIndex() {
        if Global.location != nil {
            if Global.location == "Москва" {
                lastSelectedIndexPath = IndexPath(row: 0, section: 0)
            } else if Global.location == "Санкт-Петербург" {
                lastSelectedIndexPath = IndexPath(row: 1, section: 0)
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension LocationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        let isLastSelected = lastSelectedIndexPath?.row == indexPath.row
        cell.accessoryType = isLastSelected ? .checkmark : .none
        return cell
    }
}


// MARK: - UITableViewDelegate

extension LocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.location = items[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row != lastSelectedIndexPath?.row {
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRow(at: lastSelectedIndexPath)
                oldCell?.accessoryType = .none
            }

            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark

            lastSelectedIndexPath = indexPath
        }
    }
}
