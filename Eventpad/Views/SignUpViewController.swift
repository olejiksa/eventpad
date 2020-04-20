//
//  SignUpViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import SafariServices
import UIKit

final class SignUpViewController: UIViewController {
    
    @IBOutlet private weak var loginField: UITextField!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var surnameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var phoneField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var repeatPasswordField: UITextField!
    @IBOutlet private weak var acceptTextView: UITextView!
    @IBOutlet private weak var acceptSwitch: UISwitch!
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var signUpButton: BigButton!
    
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let userDefaultsService = UserDefaultsService()
    private var formHelper: FormHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTextView()
        setupKeyboard()
        setupFormHelper()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Регистрация"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupTextView() {
        let string = "Я принимаю условия пользовательского соглашения и политики конфиденциальности"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: 77))
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: 77))
        attributedString.addAttribute(.link, value: "https://vk.com/@hseapp-terms", range: NSRange(location: 19, length: 28))
        attributedString.addAttribute(.link, value: "https://vk.com/@hseapp-privacy", range: NSRange(location: 50, length: 27))
        acceptTextView.textContainerInset = .zero
        acceptTextView.textContainer.lineFragmentPadding = 0
        acceptTextView.attributedText = attributedString
    }
    
    private func setupKeyboard() {
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [loginField,
                                         nameField,
                                         surnameField,
                                         emailField,
                                         phoneField,
                                         passwordField,
                                         repeatPasswordField]
        
        formHelper = FormHelper(textFields: textFields,
                                switches: [acceptSwitch],
                                button: signUpButton,
                                stackView: stackView)
    }
    
    private func signUp(_ signUp: SignUp) {
        let config = RequestFactory.signUp(signUp)
        
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        self.signUpButton.hideLoading()
                        
                        let alert = self.alertService.alert(response.message)
                        self.present(alert, animated: true)
                        return
                    }
                    
                    self.userDefaultsService.setToken(response.message)
                    
                    let user = User(email: signUp.email,
                                    phone: signUp.phone,
                                    name: signUp.name,
                                    surname: signUp.surname)
                    self.userDefaultsService.setUser(user)
                    self.signUpButton.hideLoading()
                    self.close()
                    
                case .failure(let error):
                    self.signUpButton.hideLoading()
                    
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction private func signUpDidTap() {
        guard
            let username = loginField.text,
            let password = passwordField.text,
            let name = nameField.text,
            let surname = surnameField.text,
            let email = emailField.text,
            let phone = phoneField.text
        else { return }
        
        signUpButton.showLoading()

        let deviceName = UIDevice.current.name
        let signUp = SignUp(username: username,
                            password: password,
                            deviceName: deviceName,
                            name: name,
                            surname: surname,
                            email: email,
                            phone: phone)
        self.signUp(signUp)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}


// MARK: - UITextViewDelegate

extension SignUpViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView,
                  shouldInteractWith url: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true

        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
        
        return false
    }
}
