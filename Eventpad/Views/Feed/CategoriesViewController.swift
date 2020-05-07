//
//  CategoriesViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 19.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class CategoriesViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var showAllSwitch: UISwitch!
    
    private let cellID = "\(UITableViewCell.self)"
    private var lastSelectedIndexPath: IndexPath?
    
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
        navigationItem.title = "По категории"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.isHidden = Global.categoryInUse == nil
        showAllSwitch.isOn = Global.categoryInUse == nil
    }

    @objc private func close() {
        dismiss(animated: true)
    }
    
    @IBAction private func showAllSwitchDidValueChange() {
        tableView.isHidden = showAllSwitch.isOn
        if showAllSwitch.isOn {
            Global.categoryInUse = nil
            lastSelectedIndexPath = nil
        } else {
            setupIndex()
        }
    }
    
    private func setupIndex() {
        if let category = Global.categoryInUse {
            lastSelectedIndexPath = IndexPath(row: category.rawValue, section: 0)
            Global.categoryInUse = category
        } else {
            lastSelectedIndexPath = IndexPath(row: 0, section: 0)
            Global.categoryInUse = Category.noCategory
        }
    }
}


// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = Category.allCases[indexPath.row].description
        let isLastSelected = lastSelectedIndexPath?.row == indexPath.row
        cell.accessoryType = isLastSelected ? .checkmark : .none
        return cell
    }
}


// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.categoryInUse = Category(rawValue: indexPath.row)
        
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
