//
//  AccountViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 30.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import AVFoundation
import MessageUI
import UIKit

final class AccountViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var emailButton: UIButton!
    @IBOutlet private weak var phoneButton: UIButton!
    @IBOutlet private weak var logoutButton: BigButton!
    @IBOutlet private weak var conferencesButton: BigButton!
    @IBOutlet private weak var validationButton: BigButton!
    @IBOutlet private weak var statsButton: BigButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private let isNotMine: Bool
    private let user: User
    private let role: Role
    private let alertService = AlertService()
    private let requestSender = RequestSender()
    private let userDefaultsService = UserDefaultsService()
    
    init(user: User, role: Role, isNotMine: Bool) {
        self.user = user
        self.role = role
        self.isNotMine = isNotMine
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
        navigationItem.largeTitleDisplayMode = .never
        
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        let shareButton = UIBarButtonItem(image: shareImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(shareDidTap))
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(editDidTap))
        
        if isNotMine {
            navigationItem.rightBarButtonItems = [shareButton]
        } else {
            navigationItem.rightBarButtonItems = [shareButton, editButton]
        }
    }
    
    private func setupView() {
        fullNameLabel.text = "\(user.name) \(user.surname)"
        accountLabel.text = role.description
        emailButton.setTitle(user.email ?? "Не указан", for: .normal)
        phoneButton.setTitle(user.phone ?? "Не указан", for: .normal)
        conferencesButton.isHidden = role != .organizer || isNotMine
        validationButton.isHidden = role != .organizer || isNotMine
        statsButton.isHidden = role != .organizer || isNotMine
        logoutButton.isHidden = isNotMine
        if let description = user.description, description != "" {
            descriptionLabel.text = user.description
        } else {
            descriptionLabel.text = "Не указано"
        }
        imageView.layer.cornerRadius = 50

        if let url = user.photoUrl, let image = convertBase64ToImage(url) {
            imageView.image = image
        }
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
        self.conferencesButton.showLoading()
        let config = RequestFactory.conferences(username: user.username, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            self.conferencesButton.hideLoading()

            switch result {
            case .success(let conferences):
                let vc = MyConferencesViewController(sections: conferences.sorted(by: { $0.dateStart > $1.dateStart}).map { EventSection(conference: $0) })
                if let splitVc = self.splitViewController, !splitVc.isCollapsed {
                    (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
                } else {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func shareDidTap(sender: UIBarButtonItem) {
        let text = user.name + " " + user.surname
        let url: URL
        switch role {
        case .organizer:
            url = URL(string: "eventpad://\(Role.organizer.name)?id=\(user.id!)")!
            
        default:
            url = URL(string: "eventpad://user?id=\(user.id!)")!
        }
        
        let sharedObjects = [url as AnyObject, text as AnyObject]
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityViewController.popoverPresentationController?.barButtonItem = sender
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func editDidTap() {
        let vc = SignUpViewController(mode: .edit(user))
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .formSheet
        present(nvc, animated: true)
    }
    
    @IBAction private func scannerDidTap() {
        guard AVCaptureDevice.default(for: .video) != nil else {
            failed()
            return
        }
        
        let vc = ScannerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func statsDidTap() {
        let vc = StatisticsViewController(username: user.username)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
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
