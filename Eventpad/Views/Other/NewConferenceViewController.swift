//
//  NewConferenceViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class NewConferenceViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var locationTextField: UITextField!
    @IBOutlet private weak var dateStartTextField: UITextField!
    @IBOutlet private weak var dateEndTextField: UITextField!
    @IBOutlet private weak var doneButton: BigButton!
    
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    private let picker = UIPickerView()
    private var formHelper: FormHelper?
    private var dateStart: Date?
    private var dateEnd: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupCategoryTextField()
        setupDateTextFields()
        setupFormHelper()
        setupKeyboard()
        setupPicker()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Новая конференция"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [titleTextField,
                                         descriptionTextField,
                                         categoryTextField,
                                         locationTextField,
                                         dateStartTextField,
                                         dateEndTextField]

        formHelper = FormHelper(textFields: textFields,
                                button: doneButton,
                                stackView: UIStackView())
    }
    
    @IBAction private func createDidTap() {
        guard
            let user = userDefaultsService.getUser(),
            let title = titleTextField.text,
            let description = descriptionTextField.text,
            let categoryName = categoryTextField.text,
            let category = Category(string: categoryName),
            let location = locationTextField.text,
            let dateStart = dateStart,
            let dateEnd = dateEnd
        else { return }
        
        doneButton.showLoading()

        let conference = Conference(id: nil,
                                    title: title,
                                    description: description,
                                    category: category,
                                    tariffs: nil,
                                    location: location,
                                    dateStart: dateStart,
                                    dateEnd: dateEnd,
                                    isCancelled: false,
                                    organizerName: user.username,
                                    organizerID: nil)
        create(conference)
    }
    
    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
    }
    
    private func setupCategoryTextField() {
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerDidEndEditing))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pickerDidEndEditing))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        categoryTextField.inputView = picker
        categoryTextField.inputAccessoryView = toolbar
    }
    
    private func setupDateTextFields() {
        dateStartTextField.setInputViewDatePicker(target: self,
                                                  selector: #selector(tapDoneStart))
        
        dateEndTextField.setInputViewDatePicker(target: self,
                                                selector: #selector(tapDoneEnd))
    }
    
    private func setupKeyboard() {
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    private func create(_ conference: Conference) {
        let config = RequestFactory.createConference(conference)
        
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        self.doneButton.hideLoading()
                        return
                    }
                    
                    self.doneButton.hideLoading()
                    self.close()
                    
                case .failure(let error):
                    self.doneButton.hideLoading()
                    
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func tapDoneStart() {
        if let datePicker = dateStartTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            dateformatter.timeStyle = .medium
            dateStartTextField.text = dateformatter.string(from: datePicker.date)
            dateStart = datePicker.date
        }
        
       dateStartTextField.resignFirstResponder()
    }
    
    @objc private func tapDoneEnd() {
        if let datePicker = dateEndTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .short
            dateformatter.timeStyle = .short
            dateEndTextField.text = dateformatter.string(from: datePicker.date)
            dateEnd = datePicker.date
        }
        
        dateEndTextField.resignFirstResponder()
    }
    
    @objc private func pickerDidEndEditing() {
        view.endEditing(true)
    }
}


// MARK: - UIPickerViewDataSource

extension NewConferenceViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return Category.allCases[row].description
    }
}


// MARK: - UIPickerViewDelegate

extension NewConferenceViewController: UIPickerViewDelegate {
 
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        categoryTextField.text = Category.allCases[row].description
    }
}


// MARK: - UITextField+InputViewDatePicker

private extension UITextField {
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let rect = CGRect(x: 0, y: 0, width: screenWidth, height: 216)
        let datePicker = UIDatePicker(frame: rect)
        datePicker.datePickerMode = .dateAndTime
        inputView = datePicker
        
        let toolBarRect = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)
        let toolBar = UIToolbar(frame: toolBarRect)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil,
                                       action: nil)
        let cancel = UIBarButtonItem(title: "Cancel",
                                     style: .plain,
                                     target: nil,
                                     action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done",
                                        style: .plain,
                                        target: target,
                                        action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        resignFirstResponder()
    }
}
