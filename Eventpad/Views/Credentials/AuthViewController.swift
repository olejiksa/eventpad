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
    @IBOutlet private weak var organizerSwitch: UISwitch!
    
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let userDefaultsService = UserDefaultsService()
    private var formHelper: FormHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupKeyboard()
        setupFormHelper()
        setupView()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Вход"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [loginField, passwordField]
        
        formHelper = FormHelper(textFields: textFields,
                                button: loginButton,
                                stackView: UIStackView())
    }
    
    private func setupKeyboard() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
        }
    }
    
    private func login(username: String, password: String) {
        let deviceName = Global.deviceToken ?? UIDevice.current.name
        let login = Login(username: username, password: password, deviceName: deviceName)
        let role: Role = organizerSwitch.isOn ? .organizer : .participant
        let loginConfig = RequestFactory.login(login: login, role: role)
        let userConfig = RequestFactory.user(username: username, role: role)
        
        requestSender.send(config: loginConfig) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        self.loginButton.hideLoading()
                        
                        let alert = self.alertService.alert(response.message)
                        self.present(alert, animated: true)
                        return
                    }
                    
                    self.userDefaultsService.setRole(role)
                    if self.rememberSwitch.isOn {
                        self.userDefaultsService.setToken(response.message)
                    }
                    
                    self.requestSender.send(config: userConfig) { [weak self] result in
                        guard let self = self else { return }
                        
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                if self.rememberSwitch.isOn {
                                    self.userDefaultsService.setUser(response)
                                }
                                
                                self.loginButton.hideLoading()
                                self.close()
                                
                            case .failure(let error):
                                self.loginButton.hideLoading()
                                
                                let alert = self.alertService.alert(error.localizedDescription)
                                self.present(alert, animated: true)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.loginButton.hideLoading()
                    
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func setupView() {
        rememberSwitch.onTintColor = UIColor.systemBlue
    }
    
    @IBAction private func loginDidTap() {
        guard
            let username = loginField.text,
            let password = passwordField.text
        else { return }
        
        loginButton.showLoading()
        
        login(username: username, password: password)
    }
    
    @IBAction private func signUpDidTap() {
        let vc = SignUpViewController(mode: .new)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}
