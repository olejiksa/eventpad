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
            
        default:
            fatalError()
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
        let description = defaults.string(forKey: "description")
        let photoUrl = defaults.string(forKey: "photoUrl")
        
        return .init(id: id,
                     username: username,
                     email: email,
                     phone: phone,
                     name: name,
                     surname: surname,
                     description: description,
                     photoUrl: photoUrl)
    }
    
    func setUser(_ user: User) {
        defaults.set(user.id, forKey: "id")
        defaults.set(user.username, forKey: "username")
        defaults.set(user.email, forKey: "email")
        defaults.set(user.phone, forKey: "phone")
        defaults.set(user.name, forKey: "name")
        defaults.set(user.surname, forKey: "surname")
        defaults.set(user.description, forKey: "description")
        defaults.set(user.photoUrl, forKey: "photoUrl")
    }
    
    func getTicketIDs() -> [String: String]? {
        return defaults.dictionary(forKey: "tickets") as? [String: String]
    }
    
    func setTicketIds(_ array: [String: String]) {
        defaults.set(array, forKey: "tickets")
    }
    
    func appendTicketId(_ id: [String: String]) {
        var ticketIds = getTicketIDs() ?? [:]
        ticketIds.merge(dict: id)
        defaults.set(ticketIds, forKey: "tickets")
    }
    
    func clear() {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach(defaults.removeObject)
        Global.accessToken = nil
        Global.role = .participant
    }
}


private extension Dictionary {
    
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
