//
//  EventDetailViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 02.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import MapKit
import UIKit

final class EventDetailViewController: UIViewController {
    
    private let userDefaultsService = UserDefaultsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Событие"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func registerDidTap() {
        if userDefaultsService.getToken() == nil {
            let vc = AuthViewController()
            let nvc = UINavigationController(rootViewController: vc)
            present(nvc, animated: true)
        }
    }
}
