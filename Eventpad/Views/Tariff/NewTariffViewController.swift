//
//  NewTariffViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class NewTariffViewController: UIViewController {

    enum Mode: Equatable {
        case new, edit(Tariff)
    }
    
    @IBOutlet private weak var doneButton: BigButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var ticketCountField: UITextField!
    @IBOutlet private weak var priceField: UITextField!
    @IBOutlet private weak var deleteButton: BigButton!
    
    var conferenceID: Int?
    var completionHandler: ((Tariff) -> ())?

    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    private var formHelper: FormHelper?
    
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
        setupKeyboard()
        setupFormHelper()
        setupView()
    }

    private func setupNavigation() {
        switch mode {
        case .new:
            navigationItem.title = "Новый тариф"

        case .edit:
            navigationItem.title = "Тариф"
        }
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupKeyboard() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            scrollView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
        }
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
    
    private func setupView() {
        switch mode {
        case .new:
            deleteButton.isHidden = true

        case .edit(let tariff):
            titleField.text = tariff.title
            priceField.text = String(Int(tariff.price))
            ticketCountField.text = String(tariff.ticketsTotalCount)
            doneButton.isHidden = true
            titleField.isUserInteractionEnabled = false
            priceField.isUserInteractionEnabled = false
            ticketCountField.isUserInteractionEnabled = false
        }
    }
    
    @IBAction private func deleteDidTap() {
        guard case Mode.edit(let tariff) = mode else { return }
        let config = RequestFactory.deleteTariff(tariffID: tariff.id!)
        
        deleteButton.showLoading()
        
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        let alert = self.alertService.alert(response.message ?? "Неизвестная ошибка")
                        self.present(alert, animated: true)
                        self.deleteButton.hideLoading()
                        return
                    }
                    
                    self.deleteButton.hideLoading()
                    self.close()
                    self.completionHandler?(tariff)
                    
                case .failure(let error):
                    self.deleteButton.hideLoading()
                    
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction private func createDidTap() {
        guard
            let conferenceID = conferenceID,
            let title = titleField.text,
            let priceString = priceField.text,
            let price = Int(priceString),
            let ticketCountString = ticketCountField.text,
            let ticketCount = Int(ticketCountString)
        else { return }
        
        switch mode {
        case .new:
            let tariff = Tariff(id: nil,
                                title: title,
                                price: Double(price),
                                conferenceID: conferenceID,
                                ticketsLeftCount: ticketCount,
                                ticketsTotalCount: ticketCount)
            create(tariff)

        case .edit(let oldTariff):
            let tariff = Tariff(id: oldTariff.id,
                                title: title,
                                price: Double(price),
                                conferenceID: conferenceID,
                                ticketsLeftCount: ticketCount,
                                ticketsTotalCount: ticketCount)
            change(tariff)
        }
    }
    
    private func create(_ tariff: Tariff) {
        guard let conferenceID = conferenceID else { return }
        let config = RequestFactory.addToConference(tariffs: [tariff], conferenceID: conferenceID)
        
        doneButton.showLoading()
        
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        let alert = self.alertService.alert(response.message ?? "Неизвестная ошибка")
                        self.present(alert, animated: true)
                        self.doneButton.hideLoading()
                        return
                    }
                    
                    self.doneButton.hideLoading()
                    self.completionHandler?(tariff)
                    self.close()
                    
                case .failure(let error):
                    self.doneButton.hideLoading()
                    
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func change(_ tariff: Tariff) {
        guard case Mode.edit(let tariff) = mode else { return }
        let config = RequestFactory.changeTariff(tariff: tariff)
        
        doneButton.showLoading()
        
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        let alert = self.alertService.alert(response.message ?? "Неизвестная ошибка")
                        self.present(alert, animated: true)
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
