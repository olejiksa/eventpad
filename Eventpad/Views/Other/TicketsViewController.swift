//
//  TicketsViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class TicketsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Билеты"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
