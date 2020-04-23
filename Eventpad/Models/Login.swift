//
//  Login.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct Login: Encodable {

    private enum CodingKeys: String, CodingKey {
        case username = "login"
        case password = "password_hash"
        case deviceName = "device_id"
    }
    
    let username: String
    let password: String
    let deviceName: String
}
