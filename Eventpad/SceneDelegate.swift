//
//  SceneDelegate.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private let userDefaultsService = UserDefaultsService()
    private let requestSender = RequestSender()
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        Global.accessToken = userDefaultsService.getToken()
        Global.role = userDefaultsService.getRole()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = TabBarBuilder.build()
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        
        #if targetEnvironment(macCatalyst)
            if let windowScene = scene as? UIWindowScene {
                if let titlebar = windowScene.titlebar {
                    let toolbar = NSToolbar(identifier: "testToolbar")
                    
                    titlebar.toolbar = toolbar
                }
                
                if let titlebar = windowScene.titlebar {
                    titlebar.titleVisibility = .hidden
                    titlebar.toolbar = nil
                }
            }
        #endif
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else { return }
        guard let view = context.url.host else { return }
        
        var parameters: [String: String] = [:]
        URLComponents(url: context.url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        
        navigate(to: view, with: parameters)
    }
    
    private func navigate(to view: String, with parameters: [String: String]) {
        // 1
        var tabBarController = window?.rootViewController as? UITabBarController
        if tabBarController == nil {
            Global.accessToken = userDefaultsService.getToken()
            Global.role = userDefaultsService.getRole()
            
            window = UIWindow(frame: UIScreen.main.bounds)
            
            tabBarController = TabBarBuilder.build()
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
        
        guard let tbc = tabBarController else { return }

        // 2
        tbc.selectedIndex = 0
        guard let svc = tbc.viewControllers?.first as? UISplitViewController else { return }
        guard let nvc = svc.children.first as? UINavigationController else { return }

        // 3
        nvc.popToRootViewController(animated: false)
        
        guard let string = parameters["id"], let id = Int(string) else { return }
        
        switch view {
        case "conference":
            let config = RequestFactory.conference(conferenceID: id)
            requestSender.send(config: config) { result in
                switch result {
                case .success(let conference):
                    let vc = ConferenceViewController(conference: conference, isManager: false)
                    if !svc.isCollapsed {
                        (svc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
                    } else {
                        nvc.pushViewController(vc, animated: true)
                    }
                    
                case .failure:
                    return
                }
            }
            
        case "user":
            let config = RequestFactory.user(userID: id, role: .participant)
            requestSender.send(config: config) { result in
                switch result {
                case .success(let user):
                    let vc = AccountViewController(user: user, role: .participant, isNotMine: true)
                    if !svc.isCollapsed {
                        (svc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
                    } else {
                        nvc.pushViewController(vc, animated: true)
                    }
                    
                case .failure:
                    return
                }
            }
            
        case "organizer":
            let config = RequestFactory.user(userID: id, role: .organizer)
            requestSender.send(config: config) { result in
                switch result {
                case .success(let user):
                    let vc = AccountViewController(user: user, role: .organizer, isNotMine: true)
                    if !svc.isCollapsed {
                        (svc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
                    } else {
                        nvc.pushViewController(vc, animated: true)
                    }
                    
                case .failure:
                    return
                }
            }
            
        case "event":
            let config = RequestFactory.event(eventID: id)
            requestSender.send(config: config) { result in
                switch result {
                case .success(let event):
                    let vc = EventViewController(event: event, isManager: false, fromFavorites: false)
                    if !svc.isCollapsed {
                        (svc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
                    } else {
                        nvc.pushViewController(vc, animated: true)
                    }
                    
                case .failure:
                    return
                }
            }
            
        case "ticket":
            let config = RequestFactory.ticket(ticketID: String(id))
            requestSender.send(config: config) { result in
                switch result {
                case .success(let ticket):
                    let string = """
                    Данный билет успешно проверен на подлинность, участник имеет право на посещение конференции
                    Выпущен: \(ticket.released)
                    ID участника: \(ticket.buyerID)
                    ID тарифа: \(ticket.tariffID)
                    """
                    let alert = AlertService().alert(string, title: .info)
                    nvc.present(alert, animated: true)
                    
                case .failure:
                    return
                }
            }
            break
            
        default:
            break
        }
    }
}
