//
//  AlertService.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 17.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit


enum AlertTitle: String {
    
    case attention = "Внимание"
    case error = "Ошибка"
    case info = "Информация"
}


protocol AlertServiceProtocol: class {
    
    func alert(_ message: String) -> UIAlertController
    func alert(_ message: String, title: AlertTitle) -> UIAlertController
    func alert(_ message: String,
               title: AlertTitle,
               isDestructive: Bool,
               okAction: @escaping ((UIAlertAction) -> ())) -> UIAlertController
}


final class AlertService: AlertServiceProtocol {
    
    init() {}
    
    func alert(_ message: String) -> UIAlertController {
        let alert = UIAlertController(title: AlertTitle.error.rawValue, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
    
    func alert(_ message: String, title: AlertTitle) -> UIAlertController {
        let alert = UIAlertController(title: title.rawValue, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
    
    func alert(_ message: String,
               title: AlertTitle,
               isDestructive: Bool,
               okAction: @escaping ((UIAlertAction) -> ())) -> UIAlertController {
        let alert = UIAlertController(title: title.rawValue, message: message, preferredStyle: .alert)
        
        if isDestructive {
            let okAction = UIAlertAction(title: "Да", style: .destructive, handler: okAction)
            let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
        } else {
            let action = UIAlertAction(title: "OK", style: .default, handler: okAction)
            alert.addAction(action)
        }
        
        return alert
    }
}
