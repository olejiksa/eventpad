//
//  TabBarBuilder.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 30.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class TabBarBuilder: UISplitViewControllerDelegate {
    
    static func build() -> UITabBarController {
        let feedSvc = self.feedSvc()
        let searchSvc = self.searchSvc()
        let ticketsSvc = self.ticketsSvc()
        let favoritesSvc = self.favoritesSvc()
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [feedSvc,
                                            searchSvc,
                                            ticketsSvc,
                                            favoritesSvc]
        
        return tabBarController
    }
    
    
    // MARK: Private
    
    private static func feedSvc() -> UISplitViewController {
        let vc = FeedViewController()
        let nvc = UINavigationController(rootViewController: vc)
        
        let emptyVc = EmptyViewController("Для просмотра информации о конференции нажмите на нее в левой части экрана")
        let emptyNvc = UINavigationController(rootViewController: emptyVc)

        let svc = UISplitViewController()
        svc.delegate = vc
        svc.preferredDisplayMode = .allVisible
        svc.viewControllers = [nvc, emptyNvc]
        
        svc.tabBarItem = UITabBarItem(title: "Афиша",
                                      image: UIImage(systemName: "house"),
                                      selectedImage: UIImage(systemName: "house.fill"))
        
        return svc
    }
    
    private static func searchSvc() -> UISplitViewController {
        let vc = SearchViewController()
        let nvc = UINavigationController(rootViewController: vc)
        
        let emptyVc = EmptyViewController("Для просмотра информации о найденном элементе нажмите на него в левой части экрана")
        let emptyNvc = UINavigationController(rootViewController: emptyVc)
        
        let svc = UISplitViewController()
        svc.delegate = vc
        svc.preferredDisplayMode = .allVisible
        svc.viewControllers = [nvc, emptyNvc]
        
        svc.tabBarItem = UITabBarItem(title: "Поиск",
                                      image: UIImage(systemName: "magnifyingglass"),
                                      selectedImage: UIImage(systemName: "magnifyingglass"))
        
        return svc
    }
    
    private static func ticketsSvc() -> UISplitViewController {
        let vc = TicketsViewController()
        let nvc = UINavigationController(rootViewController: vc)
        
        let emptyVc = EmptyViewController("Для просмотра информации о билете нажмите на него в левой части экрана")
        let emptyNvc = UINavigationController(rootViewController: emptyVc)
        
        let svc = UISplitViewController()
        svc.delegate = vc
        svc.preferredDisplayMode = .allVisible
        svc.viewControllers = [nvc, emptyNvc]
        
        svc.tabBarItem = UITabBarItem(title: "Билеты",
                                      image: UIImage(systemName: "doc.plaintext"),
                                      selectedImage: UIImage(systemName: "doc.plaintext"))
        
        return svc
    }
    
    private static func favoritesSvc() -> UISplitViewController {
        let vc = FavoritesViewController()
        let nvc = UINavigationController(rootViewController: vc)
        
        let emptyVc = EmptyViewController("Для просмотра информации об элементе в \"Избранном\" нажмите на него в левой части экрана")
        let emptyNvc = UINavigationController(rootViewController: emptyVc)

        let svc = UISplitViewController()
        svc.delegate = vc
        svc.preferredDisplayMode = .allVisible
        svc.viewControllers = [nvc, emptyNvc]
        
        svc.tabBarItem = UITabBarItem(title: "Избранное",
                                      image: UIImage(systemName: "star"),
                                      selectedImage: UIImage(systemName: "star.fill"))
        
        return svc
    }
}
