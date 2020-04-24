//
//  TabBarFactory.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 24.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class TabBarFactory {
    
    class func tabBarController() -> UITabBarController {
        let vc = FeedViewController()
        let nvc = UINavigationController(rootViewController: vc)
        nvc.tabBarItem = UITabBarItem(title: "Афиша",
                                      image: UIImage(systemName: "house"),
                                      selectedImage: UIImage(systemName: "house.fill"))
        
        let vc2 = SearchViewController()
        let nvc2 = UINavigationController(rootViewController: vc2)
        nvc2.tabBarItem = UITabBarItem(title: "Поиск",
                                       image: UIImage(systemName: "magnifyingglass"),
                                       selectedImage: UIImage(systemName: "magnifyingglass"))
        
        let vc3 = TicketsViewController()
        let nvc3 = UINavigationController(rootViewController: vc3)
        nvc3.tabBarItem = UITabBarItem(title: "Билеты",
                                       image: UIImage(systemName: "doc.plaintext"),
                                       selectedImage: UIImage(systemName: "doc.plaintext"))
        
        let vc4 = FavoritesViewController()
        let nvc4 = UINavigationController(rootViewController: vc4)
        nvc4.tabBarItem = UITabBarItem(title: "Избранное",
                                       image: UIImage(systemName: "star"),
                                       selectedImage: UIImage(systemName: "star.fill"))
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nvc, nvc2, nvc3, nvc4]
        return tabBarController
    }
}
