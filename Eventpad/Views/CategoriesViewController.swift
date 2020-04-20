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
    
    private let cellID = "\(UITableViewCell.self)"
    private let categories: [String] = ["Без категории",
                                        "Политика",
                                        "Общество",
                                        "Экономика",
                                        "Спорт",
                                        "Культура",
                                        "Технологии",
                                        "Наука",
                                        "Авто"]
    
    private var lastSelectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lastSelectedIndexPath = IndexPath(row: 0, section: 0)
    }
    
    private func setupNavigation() {
        navigationItem.title = "По категории"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}


// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        let isLastSelected = lastSelectedIndexPath?.row == indexPath.row
        cell.accessoryType = isLastSelected ? .checkmark : .none
        return cell
    }
}


// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
