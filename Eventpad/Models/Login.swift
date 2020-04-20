//
//  Login.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct Login: Decodable {

    let success: Bool
    let message: String
    
    init(success: Bool, message: String) {
        self.success = success
        self.message = message
    }
}
