//
//  NewTariffViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class NewTariffViewController: UIViewController {

    @IBOutlet private weak var doneButton: BigButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var ticketCountField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    var conferenceID: Int?
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    private var formHelper: FormHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupKeyboard()
        setupFormHelper()
    }

    private func setupNavigation() {
        navigationItem.title = "Новый тариф"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupKeyboard() {
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    private func setupFormHelper() {
        let textFields: [UITextField] = [titleField,
                                         priceField,
                                         ticketCountField]

        formHelper = FormHelper(textFields: textFields,
                                button: doneButton,
                                stackView: UIStackView())
    }
    
    @IBAction private func createDidTap() {
        guard
            let conferenceID = conferenceID,
            let title = titleField.text,
            let priceString = priceField.text,
            let price = Double(priceString),
            let ticketCountString = ticketCountField.text,
            let ticketCount = Int(ticketCountString)
        else { return }
        
        doneButton.showLoading()

        let tariff = Tariff(id: nil,
                            title: title,
                            price: price,
                            conferenceID: conferenceID,
                            ticketsLeftCount: ticketCount,
                            ticketsTotalCount: ticketCount)
        create(tariff)
    }
    
    private func create(_ tariff: Tariff) {
        guard let conferenceID = conferenceID else { return }
        let config = RequestFactory.addToConference(tariffs: [tariff], conferenceID: conferenceID)
        
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
}
