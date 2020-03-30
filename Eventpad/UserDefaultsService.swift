//
//  UserDefaultsService.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 30.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class UserDefaultsService {
    
    func get() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "login")
    }
    
    func set() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "login")
    }
    
    func clear() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach(defaults.removeObject)
    }
}
