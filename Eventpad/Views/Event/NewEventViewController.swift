//
//  NewEventViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class NewEventViewController: UIViewController {

    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var descriptionField: UITextField!
    @IBOutlet private weak var speakerField: UITextField!
    @IBOutlet private weak var dateStartField: UITextField!
    @IBOutlet private weak var dateEndField: UITextField!
    @IBOutlet private weak var doneButton: BigButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let conferenceID: Int
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    private var formHelper: FormHelper?
    private var dateStart: Date?
    private var dateEnd: Date?
    
    init(conferenceID: Int) {
        self.conferenceID = conferenceID
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupDateTextFields()
        setupFormHelper()
        setupKeyboard()
    }

    private func setupNavigation() {
        navigationItem.title = "Новое событие"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [titleField,
                                         descriptionField,
                                         speakerField,
                                         dateStartField,
                                         dateEndField]

        formHelper = FormHelper(textFields: textFields,
                                button: doneButton,
                                stackView: UIStackView())
    }
    
    private func setupDateTextFields() {
        dateStartField.setInputViewDatePicker(target: self,
                                              selector: #selector(tapDoneStart))
        
        dateEndField.setInputViewDatePicker(target: self,
                                            selector: #selector(tapDoneEnd))
    }
    
    private func setupKeyboard() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
        }
    }
    
    @objc private func tapDoneStart() {
        if let datePicker = dateStartField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            dateformatter.timeStyle = .medium
            dateStartField.text = dateformatter.string(from: datePicker.date)
            dateStart = datePicker.date
        }
        
       dateStartField.resignFirstResponder()
    }
    
    @objc private func tapDoneEnd() {
        if let datePicker = dateEndField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .short
            dateformatter.timeStyle = .short
            dateEndField.text = dateformatter.string(from: datePicker.date)
            dateEnd = datePicker.date
        }
        
        dateEndField.resignFirstResponder()
    }
    
    @objc private func pickerDidEndEditing() {
        view.endEditing(true)
    }
    
    @IBAction private func doneDidTap() {
        guard
            let title = titleField.text,
            let description = descriptionField.text,
            let speakerName = speakerField.text,
            let dateStart = dateStart,
            let dateEnd = dateEnd else { return }
        
        let event = Event(id: nil,
                          dateStart: dateStart,
                          dateEnd: dateEnd,
                          isLeaf: true,
                          conferenceID: conferenceID,
                          speakerName: speakerName,
                          speakerID: nil,
                          title: title,
                          description: description,
                          photoUrl: nil)
        let config = RequestFactory.addToConference(events: [event],
                                                    conferenceID: conferenceID)
        requestSender.send(config: config) { result in
            switch result {
            case .success(let success):
                guard success.success else {
                    let alert = self.alertService.alert(success.message!)
                    self.present(alert, animated: true)
                    return
                }
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
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
                                     action: #selector(cancelDidTap))
        let barButton = UIBarButtonItem(title: "Done",
                                        style: .plain,
                                        target: target,
                                        action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        inputAccessoryView = toolBar
    }
    
    @objc func cancelDidTap() {
        resignFirstResponder()
    }
}
