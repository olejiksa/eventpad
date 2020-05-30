//
//  NewEventViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class NewEventViewController: UIViewController {

    enum Mode: Equatable {
        case new, edit(Event)
    }
    
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var speakerField: UITextField!
    @IBOutlet private weak var dateStartField: UITextField!
    @IBOutlet private weak var dateEndField: UITextField!
    @IBOutlet private weak var doneButton: BigButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var noAvatarLabel: UILabel!
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    var imagePicker: ImagePicker!
    
    private let conferenceID: Int
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    private var formHelper: FormHelper?
    private var dateStart: Date?
    private var dateEnd: Date?
    private var event: Event?
    private let mode: Mode
    
    init(conferenceID: Int, mode: Mode) {
        self.conferenceID = conferenceID
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupView()
        setupDateTextFields()
        setupFormHelper()
        setupImagePicker()
        setupKeyboard()
    }

    private func setupNavigation() {
        navigationItem.title = mode == .new ? "Новое событие" : "Изменить событие"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    private func setupView() {
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.clipsToBounds = true
        
        switch mode {
        case .edit(let event):
            self.event = event
            titleField.text = event.title
            descriptionTextView.text = event.description
            if let photoUrl = event.photoUrl {
                avatarImageView.image = convertBase64ToImage(photoUrl)
                avatarView.isHidden = avatarImageView.image == nil
                noAvatarLabel.isHidden = avatarImageView.image != nil
            }
            speakerField.text = event.speakerName
            
            dateStart = event.dateStart
            dateEnd = event.dateEnd
            
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            dateformatter.timeStyle = .short
            dateStartField.text = dateformatter.string(from: dateStart!)
            dateEndField.text = dateformatter.string(from: dateEnd!)
            
        case .new:
            break
        }
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [titleField,
                                         speakerField,
                                         dateStartField,
                                         dateEndField]

        formHelper = FormHelper(textFields: textFields,
                                button: doneButton,
                                stackView: UIStackView())
    }
    
    private func setupDateTextFields() {
        dateStartField.setStartInputViewDatePicker(target: self, selector: #selector(tapDoneStart), date: event?.dateStart)
        dateEndField.setEndInputViewDatePicker(target: self, selector: #selector(tapDoneEnd), date: event?.dateEnd)
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
            dateformatter.timeStyle = .short
            dateStartField.text = dateformatter.string(from: datePicker.date)
            dateStart = datePicker.date
            dateEnd = datePicker.date.addingTimeInterval(3600)
            if let dateEnd = dateEnd {
                (dateEndField.inputView as? UIDatePicker)?.date = dateEnd
                dateEndField.text = dateformatter.string(from: dateEnd)
            }
        }
        
       dateStartField.resignFirstResponder()
    }
    
    @objc private func tapDoneEnd() {
        if let datePicker = dateEndField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
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
            let description = descriptionTextView.text,
            let speakerName = speakerField.text,
            let dateStart = dateStart,
            let dateEnd = dateEnd else { return }
        
        let photoUrl: String
        if let image = avatarImageView.image {
            photoUrl = convertImageToBase64(image)
        } else {
            photoUrl = ""
        }
        
        doneButton.showLoading()
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        dateComponent.day = 1
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: dateEnd)!
        
        switch  mode {
        case .new:
            let event = Event(id: nil,
                              dateStart: dateStartFinal,
                              dateEnd: dateEndFinal,
                              isLeaf: true,
                              conferenceID: conferenceID,
                              speakerName: speakerName,
                              speakerID: nil,
                              title: title,
                              description: description,
                              photoUrl: photoUrl)
            let config = RequestFactory.addToConference(events: [event],
                                                        conferenceID: conferenceID)
            requestSender.send(config: config) { [weak self] result in
                guard let self = self else { return }
                self.doneButton.showLoading()
                
                switch result {
                case .success(let success):
                    guard success.success else {
                        let alert = self.alertService.alert(success.message!)
                        self.present(alert, animated: true)
                        return
                    }
                    
                    self.dismiss(animated: true)
                    
                case .failure(let error):
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
            
        case .edit(let oldEvent):
            let event = Event(id: oldEvent.id,
                              dateStart: dateStartFinal,
                              dateEnd: dateEndFinal,
                              isLeaf: true,
                              conferenceID: conferenceID,
                              speakerName: speakerName,
                              speakerID: nil,
                              title: title,
                              description: description,
                              photoUrl: photoUrl)
            let config = RequestFactory.changeEvent(event)
            requestSender.send(config: config) { [weak self] result in
                guard let self = self else { return }
                self.doneButton.showLoading()
                
                switch result {
                case .success(let success):
                    guard success.success else {
                        let alert = self.alertService.alert(success.message!)
                        self.present(alert, animated: true)
                        return
                    }
                    
                    self.dismiss(animated: true)
                    
                case .failure(let error):
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func setupImagePicker() {
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        avatarView.layer.cornerRadius = 10
        avatarImageView.layer.cornerRadius = 10
    }
}



// MARK: - UITextField+InputViewDatePicker

private extension UITextField {
    
    func setStartInputViewDatePicker(target: Any, selector: Selector, date: Date? = nil) {
        let screenWidth = UIScreen.main.bounds.width
        let rect = CGRect(x: 0, y: 0, width: screenWidth, height: 216)
        let datePicker = UIDatePicker(frame: rect)
        datePicker.datePickerMode = .dateAndTime
        if let date = date {
            datePicker.date = date
        }
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
    
    func setEndInputViewDatePicker(target: Any, selector: Selector, date: Date? = nil) {
        let screenWidth = UIScreen.main.bounds.width
        let rect = CGRect(x: 0, y: 0, width: screenWidth, height: 216)
        let datePicker = UIDatePicker(frame: rect)
        datePicker.datePickerMode = .dateAndTime
        if let date = date {
            datePicker.date = date
        }
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


// MARK: - ImagePickerDelegate

extension NewEventViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        avatarImageView.image = image
        
        avatarView.isHidden = image == nil
        noAvatarLabel.isHidden = image != nil
        
        doneButton.isEnabled = true
    }
}
