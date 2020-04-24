//
//  FormHelper.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 29.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class FormHelper: NSObject {
 
    private let textFields: [UITextField]
    private let switches: [UISwitch]
    private let button: UIButton
    private var stackView: UIStackView
    
    private let matchLabel: UILabel = {
        let label = UILabel()
        label.text = "Введеные пароли не совпадают"
        label.textColor = .systemRed
        label.isHidden = true
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let passwordLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Пароль должен содержать не меньше 6 символов"
        label.textColor = .systemRed
        label.isHidden = true
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    init(textFields: [UITextField],
         switches: [UISwitch] = [],
         button: UIButton,
         stackView: UIStackView) {
        self.textFields = textFields
        self.switches = switches
        self.button = button
        self.stackView = stackView
        
        super.init()
        
        stackView.addArrangedSubview(matchLabel)
        stackView.addArrangedSubview(passwordLengthLabel)
        
        setupTextFields()
        checkForEmptyFields()
    }
    
    private func setupTextFields() {
        for textField in textFields {
            textField.addTarget(self,
                                action: #selector(textFieldsIsNotEmpty),
                                for: .editingChanged)
            textField.delegate = self
        }
        
        for item in switches {
            item.addTarget(self,
                           action: #selector(checkForEmptyFields),
                           for: .valueChanged)
        }
    }
    
    @objc private func textFieldsIsNotEmpty(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        checkForEmptyFields()
    }
    
    @objc private func checkForEmptyFields() {
        var passwords: Set<String> = []
        
        for textField in textFields {
            guard let textFieldVar = textField.text, !textFieldVar.isEmpty else {
                button.isEnabled = false
                matchLabel.isHidden = true
                return
            }
            
            if textField.textContentType == .some(.password) {
                passwords.insert(textFieldVar)
            }
            
            if textField.textContentType == .some(.emailAddress), !isValidEmail(textFieldVar) {
                button.isEnabled = false
                return
            }
            
            if textField.textContentType == .some(.password), textFieldVar.count < 6 {
                button.isEnabled = false
                passwordLengthLabel.isHidden = false
                return
            } else {
                passwordLengthLabel.isHidden = true
            }
        }
        
        if passwords.isEmpty {
            button.isEnabled = true
        } else {
            let matched = passwords.count == 1
            matchLabel.isHidden = matched
            button.isEnabled = matched
        }
        
        for item in switches {
            guard item.isOn else {
                button.isEnabled = false
                return
            }
            
            continue
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}


// MARK: - UITextFieldDelegate

extension FormHelper: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = textFields.firstIndex(of: textField) else { return false }
        
        if index + 1 < textFields.count {
            textFields[index + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
