//
//  TicketViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 08.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import PassKit
import UIKit

final class TicketViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateEndLabel: UILabel!
    @IBOutlet private weak var dateStartLabel: UILabel!
    @IBOutlet private weak var calendarButton: BigButton!
    @IBOutlet private weak var reminderButton: BigButton!
    @IBOutlet private weak var scheduleButton: BigButton!
    @IBOutlet private weak var mapButton: BigButton!
    @IBOutlet private weak var contactButton: BigButton!
    @IBOutlet private weak var bottomStackView: UIStackView!
    
    private let conference: Conference
    
    init(conference: Conference) {
        self.conference = conference
        
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
        navigationItem.title = "Билет"
        navigationItem.largeTitleDisplayMode = .never
        
        let printImage = UIImage(systemName: "printer")
        let printButton = UIBarButtonItem(image: printImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(printDidTap))
        navigationItem.rightBarButtonItem = printButton
    }
    
    private func setupView() {
        let passButton = PKAddPassButton(addPassButtonStyle: .blackOutline)
        passButton.addTarget(self, action: #selector(passButtonDidTap), for: .touchUpInside)
        bottomStackView.addArrangedSubview(passButton)
    }
    
    @IBAction func calendarDidTap() {
    }
    
    @IBAction func reminderDidTap() {
    }
    
    @IBAction func scheduleDidTap() {
    }

    @IBAction func mapDidTap() {
    }
    
    @IBAction func contactDidTap() {
    }
    
    @objc private func printDidTap() {
        
    }
    
    @objc private func passButtonDidTap() {
        
    }
}
