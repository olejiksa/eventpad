//
//  SignUp.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct SignUp: Encodable {
    
    private enum CodingKeys: String, CodingKey {
        case username = "login"
        case password = "password_hash"
        case deviceName = "device_id"
        case name
        case surname
        case email
        case phone
        case description
        case photoUrl
    }
    
    let username: String
    let password: String
    let deviceName: String
    let name: String
    let surname: String
    let email: String
    let phone: String
    let description: String?
    let photoUrl: String?
}
