//
//  TicketsViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class TicketsViewController: UIViewController {
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет билетов"
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupNoDataLabel()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Билеты"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupNoDataLabel() {
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
}
