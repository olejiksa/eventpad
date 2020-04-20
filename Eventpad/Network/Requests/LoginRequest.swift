//
//  LoginRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class LoginRequest: BasePostRequest {
    
    init(username: String,
         password: String,
         deviceName: String) {
        let endpoint = "\(RequestFactory.endpointRoot)login/user"
        let parameters = ["login": username,
                          "password_hash": password,
                          "device_id": deviceName]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
}
