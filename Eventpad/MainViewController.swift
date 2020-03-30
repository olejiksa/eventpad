//
//  MainViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {

    @IBOutlet private weak var logoutButton: BigButton!
    
    private let userDefaultsService = UserDefaultsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Главная"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction private func logoutDidTap() {
        logoutButton.showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let vc = AuthViewController()
            Utils.hostViewController(vc)
            
            self.userDefaultsService.clear()
            
            self.logoutButton.hideLoading()
        }
    }
}
