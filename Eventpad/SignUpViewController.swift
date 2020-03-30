//
//  SignUpViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    @IBOutlet private weak var loginField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var repeatPasswordField: UITextField!
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var signUpButton: BigButton!
    
    private var formHelper: FormHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
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
    
    private func setupKeyboard() {
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [loginField,
                                         passwordField,
                                         repeatPasswordField]
        
        formHelper = FormHelper(textFields: textFields,
                                requiredTextFields: textFields,
                                button: signUpButton,
                                stackView: stackView)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @IBAction private func signUpDidTap() {
        signUpButton.showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.close()
            self.signUpButton.hideLoading()
        }
    }
}
