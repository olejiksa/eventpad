//
//  AccountViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 30.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import MessageUI
import UIKit

final class AccountViewController: UIViewController {

    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var emailButton: UIButton!
    @IBOutlet private weak var phoneButton: UIButton!
    @IBOutlet private weak var logoutButton: BigButton!
    @IBOutlet private weak var conferencesButton: BigButton!
    
    private let user: User
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupView()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Учетная запись"
    }
    
    private func setupView() {
        fullNameLabel.text = "\(user.name) \(user.surname)"
        accountLabel.text = Global.role.description
        emailButton.setTitle(user.email, for: .normal)
        phoneButton.setTitle(user.phone, for: .normal)
        conferencesButton.isHidden = Global.role == .participant
    }
    
    @IBAction private func logoutDidTap() {
        logoutButton.showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.userDefaultsService.clear()
            self.logoutButton.hideLoading()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func emailDidTap() {
        guard let email = user.email else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            
            present(mail, animated: true)
        } else {
            let alert = alertService.alert("Не удалось отправить сообщение электронной почты. Пожалуйста, убедитесь, что на вашем устройстве установлено стандартное приложение для работы с почтой, и повторите попытку.")
            present(alert, animated: true)
        }
    }
    
    @IBAction private func phoneDidTap() {
        guard let phone = user.phone else { return }
        
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let alert = alertService.alert("Не удалось позвонить по номеру телефона. Возможно, он является некорректным либо ваше устройство не поддерживает телефонию.")
            present(alert, animated: true)
        }
    }
    
    @IBAction private func myConferencesDidTap() {
        let vc = MyConferencesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension AccountViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
