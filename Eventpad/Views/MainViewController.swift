//
//  MainViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let userDefaultsService = UserDefaultsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Афиша"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let userImage = UIImage(systemName: "person.crop.circle")
        let userButton = UIBarButtonItem(image: userImage,
                                                style: .plain,
                                                target: self,
                                                action: #selector(userDidTap))
        navigationItem.rightBarButtonItem = userButton
    }
    
    @IBAction private func userDidTap() {
        if userDefaultsService.get() {
            let vc = AccountViewController()
            let nvc = UINavigationController(rootViewController: vc)
            present(nvc, animated: true)
        } else {
            let vc = AuthViewController()
            let nvc = UINavigationController(rootViewController: vc)
            present(nvc, animated: true)
        }
    }
}
