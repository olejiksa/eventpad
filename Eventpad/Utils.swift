//
//  Utils.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 30.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class Utils {
    
    class func hostViewController(_ viewController: UIViewController) {
        let scene = UIApplication.shared.connectedScenes.first
        if let mySceneDelegate = scene?.delegate as? SceneDelegate {
            let nvc = UINavigationController(rootViewController: viewController)
            mySceneDelegate.window?.rootViewController = nvc
        }
    }
}
