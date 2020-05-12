//
//  OrganizerSignUpViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 22.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import SafariServices
import UIKit

final class OrganizerSignUpViewController: UIViewController {
    
    @IBOutlet private weak var doneButton: BigButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var agreementTextView: UITextView!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var organizationTextField: UITextField!
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var phoneTextField: UITextField!
    
    private var formHelper: FormHelper?
    private let picker = UIPickerView()
    private let options = ["Буду продавать билеты",
                           "Открою бесплатную регистрацию",
                           "Пока тестирую сервис"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupKeyboard()
        setupPicker()
        setupTextView()
        setupTextField()
        setupFormHelper()
    }

    private func setupNavigation() {
        navigationItem.title = "Новая организация"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupKeyboard() {
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    private func setupTextView() {
        let attributedString = NSMutableAttributedString(string: "Я ознакомлен и подтверждаю свое согласие с условиями лицензионных договоров: базового, билетного и pro-договора",
                                                         attributes: [.font: UIFont.systemFont(ofSize: 17),
                                                                      .foregroundColor: UIColor.label])
        attributedString.addAttribute(.link, value: URL(string: "https://timepad.ru/download2/TimePad_license_agreement_free.pdf?path=/files/docs/0/TimePad_license_agreement_free.pdf&e=1574240918&st=o6stDstiI3gkwMmhF4RHAp1OBGs%3D")!, range: NSMakeRange(77, 8))
        attributedString.addAttribute(.link, value: URL(string: "https://timepad.ru/download2/TimePad_license_agreement_ticketing.pdf?path=/files/docs/0/TimePad_license_agreement_ticketing.pdf&e=1574195548&st=j%2Fqxwi%2FLz%2Fu2dR40b0K0ZlcTaBE%3D")!, range: NSMakeRange(87, 9))
        attributedString.addAttribute(.link, value: URL(string: "https://timepad.ru/download2/TimePad_license_agreement_pro.pdf?path=/files/docs/0/TimePad_license_agreement_pro.pdf&e=1574195564&st=%2BVpDS5ax6HSq79X%2Byhn%2FQVoEh2Y%3D")!, range: NSMakeRange(99, 3))
        
        agreementTextView.attributedText = attributedString
        agreementTextView.textContainerInset = .zero
        agreementTextView.textContainer.lineFragmentPadding = 0
    }
    
    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
    }
    
    private func setupTextField() {
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerDidEndEditing))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pickerDidEndEditing))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        descriptionTextField.inputView = picker
        descriptionTextField.inputAccessoryView = toolbar
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [organizationTextField,
                                         urlTextField,
                                         phoneTextField,
                                         descriptionTextField]
        
        formHelper = FormHelper(textFields: textFields,
                                button: doneButton,
                                stackView: UIStackView())
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc private func pickerDidEndEditing() {
        view.endEditing(true)
    }
}


// MARK: - UITextViewDelegate

extension OrganizerSignUpViewController: UITextViewDelegate {
    
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


// MARK: - UIPickerViewDataSource

extension OrganizerSignUpViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return options[row]
    }
}


// MARK: - UIPickerViewDelegate

extension OrganizerSignUpViewController: UIPickerViewDelegate {
 
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
       descriptionTextField.text = options[row]
    }
}
