//
//  NewConferenceViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class NewConferenceViewController: UIViewController {

    enum Mode: Equatable {
        case new, edit(Conference)
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var locationTextField: UITextField!
    @IBOutlet private weak var dateStartTextField: UITextField!
    @IBOutlet private weak var dateEndTextField: UITextField!
    @IBOutlet private weak var doneButton: BigButton!
    
    @IBOutlet private weak var noAvatarLabel: UILabel!
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    var imagePicker: ImagePicker!
    
    private var conference: Conference?
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    private let picker = UIPickerView()
    private var formHelper: FormHelper?
    private var dateStart: Date?
    private var dateEnd: Date?
    private let mode: Mode
    
    init(mode: Mode) {
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
        setupCategoryTextField()
        setupDateTextFields()
        setupFormHelper()
        setupKeyboard()
        setupPicker()
        setupImagePicker()
    }
    
    private func setupImagePicker() {
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        avatarView.layer.cornerRadius = 10
        avatarImageView.layer.cornerRadius = 10
    }
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    private func setupNavigation() {
        navigationItem.title = mode == .new ? "Новая конференция" : "Изменение конференции"
        
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
            let description = descriptionTextView.text,
            let categoryName = categoryTextField.text,
            let category = Category(string: categoryName),
            let location = locationTextField.text,
            let dateStart = dateStart,
            let dateEnd = dateEnd
        else { return }
        
        doneButton.showLoading()
        
        let photoUrl: String
        if let image = avatarImageView.image {
            photoUrl = convertImageToBase64(image)
        } else {
            photoUrl = ""
        }
        
        var dateComponent = DateComponents()
        dateComponent.year = 31
        dateComponent.day = 1
        let dateStartFinal = Calendar.current.date(byAdding: dateComponent, to: dateStart)!
        let dateEndFinal = Calendar.current.date(byAdding: dateComponent, to: dateEnd)!
        
        if let conference = conference {
            let conference = Conference(id: conference.id,
                                        title: title,
                                        description: description,
                                        category: category,
                                        tariffs: nil,
                                        location: location,
                                        dateStart: dateStartFinal,
                                        dateEnd: dateEndFinal,
                                        isCancelled: false,
                                        organizerName: user.username,
                                        organizerID: nil,
                                        photoUrl: photoUrl)
            update(conference)
        } else {
            let conference = Conference(id: nil,
                                        title: title,
                                        description: description,
                                        category: category,
                                        tariffs: nil,
                                        location: location,
                                        dateStart: dateStartFinal,
                                        dateEnd: dateEndFinal,
                                        isCancelled: false,
                                        organizerName: user.username,
                                        organizerID: nil,
                                        photoUrl: photoUrl)
            create(conference)
        }
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
        dateStartTextField.setStartInputViewDatePicker(target: self,
                                                       selector: #selector(tapDoneStart), date: conference?.dateStart)
        
        dateEndTextField.setEndInputViewDatePicker(target: self,
                                                   selector: #selector(tapDoneEnd), date: conference?.dateEnd)
    }
    
    private func setupKeyboard() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
        }
    }
    
    private func setupView() {
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.clipsToBounds = true
        
        switch mode {
        case .edit(let conference):
            self.conference = conference
            titleTextField.text = conference.title
            descriptionTextView.text = conference.description
            if let photoUrl = conference.photoUrl {
                avatarImageView.image = convertBase64ToImage(photoUrl)
                avatarView.isHidden = avatarImageView.image == nil
                noAvatarLabel.isHidden = avatarImageView.image != nil
            }
            categoryTextField.text = conference.category.description
            locationTextField.text = conference.location
            
            dateStart = conference.dateStart
            dateEnd = conference.dateEnd
            
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            dateformatter.timeStyle = .short
            dateStartTextField.text = dateformatter.string(from: dateStart!)
            dateEndTextField.text = dateformatter.string(from: dateEnd!)
            
        case .new:
            break
        }
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
    
    private func update(_ conference: Conference) {
        let config = RequestFactory.changeConference(conference)
        
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
            dateformatter.timeStyle = .short
            dateStartTextField.text = dateformatter.string(from: datePicker.date)
            dateStart = datePicker.date
            dateEnd = datePicker.date.addingTimeInterval(3600)
            if let dateEnd = dateEnd {
                (dateEndTextField.inputView as? UIDatePicker)?.date = dateEnd
                dateEndTextField.text = dateformatter.string(from: dateEnd)
            }
        }
        
        dateStartTextField.resignFirstResponder()
        doneButton.isEnabled = true
    }
    
    @objc private func tapDoneEnd() {
        if let datePicker = dateEndTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            dateformatter.timeStyle = .short
            dateEndTextField.text = dateformatter.string(from: datePicker.date)
            dateEnd = datePicker.date
        }
        
        dateEndTextField.resignFirstResponder()
        doneButton.isEnabled = true
    }
    
    @objc private func pickerDidEndEditing() {
        view.endEditing(true)
        doneButton.isEnabled = true
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
                                     action: #selector(tapCancel))
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
                                     action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done",
                                        style: .plain,
                                        target: target,
                                        action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        inputAccessoryView = toolBar
    }
    
    @objc private func tapCancel() {
        resignFirstResponder()
    }
}


// MARK: - ImagePickerDelegate

extension NewConferenceViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        avatarImageView.image = image
        
        avatarView.isHidden = image == nil
        noAvatarLabel.isHidden = image != nil
        
        doneButton.isEnabled = true
    }
}
