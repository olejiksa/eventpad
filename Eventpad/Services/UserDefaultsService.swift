//
//  UserDefaultsService.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 30.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class UserDefaultsService {
    
    private let defaults = UserDefaults.standard
    
    func getToken() -> String? {
        return defaults.string(forKey: "token")
    }
    
    func setToken(_ token: String) {
        Global.accessToken = token
        defaults.set(token, forKey: "token")
    }
    
    func getRole() -> Role {
        guard getToken() != nil else { return .participant }
        return defaults.bool(forKey: "is_organizer") ? .organizer : .participant
    }
    
    func setRole(_ role: Role) {
        Global.role = role
        
        switch role {
        case .organizer:
            defaults.set(true, forKey: "is_organizer")
            
        case .participant:
            defaults.set(false, forKey: "is_organizer")
        }
    }
    
    func getUser() -> User? {
        guard
            let username = defaults.string(forKey: "username"),
            let email = defaults.string(forKey: "email"),
            let phone = defaults.string(forKey: "phone"),
            let name = defaults.string(forKey: "name"),
            let surname = defaults.string(forKey: "surname")
        else { return nil }
        
        let id = defaults.integer(forKey: "id")
        
        return .init(id: id,
                     username: username,
                     email: email,
                     phone: phone,
                     name: name,
                     surname: surname)
    }
    
    func setUser(_ user: User) {
        defaults.set(user.id, forKey: "id")
        defaults.set(user.username, forKey: "username")
        defaults.set(user.email, forKey: "email")
        defaults.set(user.phone, forKey: "phone")
        defaults.set(user.name, forKey: "name")
        defaults.set(user.surname, forKey: "surname")
    }
    
    func clear() {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach(defaults.removeObject)
    }
}