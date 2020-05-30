//
//  EmptyViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 30.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class EmptyViewController: UIViewController {

    @IBOutlet private weak var infoLabel: UILabel!
    
    private let message: String
    
    override func viewDidLoad() {
        super.viewDidLoad()

        infoLabel.text = message
    }

    init(_ message: String) {
        self.message = message
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
