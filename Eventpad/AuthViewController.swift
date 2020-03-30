//
//  AuthViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import KeyboardAdjuster
import UIKit

final class AuthViewController: UIViewController {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var loginButton: BigButton!
    @IBOutlet private weak var loginField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var rememberSwitch: UISwitch!
    
    private let userDefaultsService = UserDefaultsService()
    private var formHelper: FormHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupKeyboard()
        setupFormHelper()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Вход"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [loginField, passwordField]
        
        formHelper = FormHelper(textFields: textFields,
                                requiredTextFields: textFields,
                                button: loginButton,
                                stackView: UIStackView())
    }
    
    private func setupKeyboard() {
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    @IBAction private func loginDidTap() {
        loginButton.showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.userDefaultsService.set(self.rememberSwitch.isOn)
            
            let vc = MainViewController()
            Utils.hostViewController(vc)
            
            self.loginButton.hideLoading()
        }
    }
    
    @IBAction private func signUpDidTap() {
        let vc = SignUpViewController()
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
}
