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
    
    enum Mode: Equatable {
        case new, edit(User)
    }
    
    @IBOutlet private weak var loginField: UITextField!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var surnameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var phoneField: UITextField!
    @IBOutlet private weak var descriptionField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var repeatPasswordField: UITextField!
    @IBOutlet private weak var acceptTextView: UITextView!
    @IBOutlet private weak var acceptSwitch: UISwitch!
    @IBOutlet private weak var organizerSwitch: UISwitch!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var signUpButton: BigButton!
    @IBOutlet private weak var doneButton: BigButton!
    @IBOutlet private weak var repeatPasswordLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var stackView1: UIStackView!
    @IBOutlet private weak var stackView2: UIStackView!
    
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let userDefaultsService = UserDefaultsService()
    private var formHelper: FormHelper?
    private let mode: Mode
    private var user: User?
    
    @IBOutlet private weak var imageNameLabel: UILabel!
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    var imagePicker: ImagePicker!
    
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
        setupTextViews()
        setupKeyboard()
        setupFormHelper()
        setupImagePicker()
        setupView()
    }
    
    private func setupView() {
        switch mode {
        case .edit(let user):
            self.user = user
            loginField.text = user.username
            nameField.text = user.name
            if let photoUrl = user.photoUrl {
                avatarImageView.image = convertBase64ToImage(photoUrl)
                avatarView.isHidden = avatarImageView.image == nil
                imageNameLabel.isHidden = avatarImageView.image != nil
            }
            
            surnameField.text = user.surname
            emailField.text = user.email
            phoneField.text = user.phone
            descriptionField.text = user.description
            
            passwordField.isHidden = true
            repeatPasswordField.isHidden = true
            acceptTextView.isHidden = true
            acceptSwitch.isHidden = true
            organizerSwitch.isHidden = true
            passwordLabel.isHidden = true
            stackView1.isHidden = true
            stackView2.isHidden = true
            repeatPasswordLabel.isHidden = true
            signUpButton.isHidden = true
            doneButton.isHidden = false
            
        case .new:
            break
        }
    }
    
    private func setupNavigation() {
        navigationItem.title = mode == .new ? "Регистрация" : "Изменение профиля"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupTextViews() {
        let acceptString = "Я принимаю условия пользовательского соглашения и политики конфиденциальности"
        let acceptAttributedString = NSMutableAttributedString(string: acceptString)
        acceptAttributedString.addAttribute(.font,
                                            value: UIFont.systemFont(ofSize: 17),
                                            range: NSRange(location: 0, length: 77))
        acceptAttributedString.addAttribute(.foregroundColor,
                                            value: UIColor.label,
                                            range: NSRange(location: 0, length: 77))
        acceptAttributedString.addAttribute(.link,
                                            value: "https://vk.com/@hseapp-terms",
                                            range: NSRange(location: 19, length: 28))
        acceptAttributedString.addAttribute(.link,
                                            value: "https://vk.com/@hseapp-privacy",
                                            range: NSRange(location: 50, length: 27))
        acceptTextView.textContainerInset = .zero
        acceptTextView.textContainer.lineFragmentPadding = 0
        acceptTextView.attributedText = acceptAttributedString
    }
    
    private func setupKeyboard() {
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    private func setupFormHelper() {
        if mode == .new {
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
        } else {
            let textFields: [UITextField] = [loginField,
                                             nameField,
                                             surnameField,
                                             emailField,
                                             phoneField]
            
            formHelper = FormHelper(textFields: textFields,
                                    switches: [],
                                    button: doneButton,
                                    stackView: stackView)
        }
    }
    
    private func setupImagePicker() {
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        avatarView.layer.cornerRadius = 10
        avatarImageView.layer.cornerRadius = 10
    }
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        imagePicker.present(from: sender)
    }
    
    private func signUp(_ signUp: SignUp) {
        let role: Role = organizerSwitch.isOn ? .organizer : .participant
        let config = RequestFactory.signUp(signUp, role: role)
        
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        self.signUpButton.hideLoading()
                        self.doneButton.hideLoading()
                        
                        let alert = self.alertService.alert(response.message)
                        self.present(alert, animated: true)
                        return
                    }
                    
                    self.userDefaultsService.setRole(role)
                    self.userDefaultsService.setToken(response.message)
                    
                    let user = User(id: 0,
                                    username: signUp.username,
                                    email: signUp.email,
                                    phone: signUp.phone,
                                    name: signUp.name,
                                    surname: signUp.surname,
                                    description: signUp.description,
                                    photoUrl: nil)
                    self.userDefaultsService.setUser(user)
                    self.signUpButton.hideLoading()
                    self.doneButton.hideLoading()
                    self.close()
                    
                case .failure(let error):
                    self.signUpButton.hideLoading()
                    self.doneButton.hideLoading()
                    
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
            let phone = phoneField.text,
            let description = descriptionField.text
        else { return }
        
        signUpButton.showLoading()
        doneButton.showLoading()

        switch mode {
        case .new:
            let deviceName = Global.deviceToken ?? UIDevice.current.name
            let signUp = SignUp(username: username,
                                password: password,
                                deviceName: deviceName,
                                name: name,
                                surname: surname,
                                email: email,
                                phone: phone,
                                description: description,
                                photoUrl: nil)
            self.signUp(signUp)
            
        case .edit(let oldUser):
            let photoUrl: String
            if let image = avatarImageView.image {
                photoUrl = convertImageToBase64(image)
            } else {
                photoUrl = ""
            }
            
            let user = User(id: nil, username: oldUser.username, email: email, phone: phone, name: name, surname: surname, description: description, photoUrl: photoUrl)
            
            let config = RequestFactory.changeUser(user: user)
            
            requestSender.send(config: config) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        guard response.success else {
                            self.doneButton.hideLoading()
                            return
                        }
                        
                        self.userDefaultsService.setUser(user)
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


// MARK: - ImagePickerDelegate

extension SignUpViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        avatarImageView.image = image
        
        avatarView.isHidden = image == nil
        imageNameLabel.isHidden = image != nil
        
        doneButton.isEnabled = true
    }
}
