//
//  User.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 18.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct User: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username = "login"
        case email
        case phone
        case name
        case surname
    }
    
    let id: Int
    let username: String
    let email: String?
    let phone: String?
    let name: String
    let surname: String
}
