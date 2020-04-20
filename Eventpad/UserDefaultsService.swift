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
        defaults.set(token, forKey: "token")
    }
    
    func getUser() -> User? {
        guard
            let email = defaults.string(forKey: "email"),
            let phone = defaults.string(forKey: "phone"),
            let name = defaults.string(forKey: "name"),
            let surname = defaults.string(forKey: "surname")
        else { return nil }
        
        return .init(email: email,
                     phone: phone,
                     name: name,
                     surname: surname)
    }
    
    func setUser(_ user: User) {
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
