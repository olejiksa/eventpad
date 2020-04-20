//
//  SignUpRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class SignUpRequest: BasePostRequest {
    
    init(_ signUp: SignUp) {
        let endpoint = "\(RequestFactory.endpointRoot)reg/user"
        let parameters = ["login": signUp.username,
                          "password_hash": signUp.password,
                          "device_id": signUp.deviceName,
                          "name": signUp.name,
                          "surname": signUp.surname,
                          "email": signUp.email,
                          "phone": signUp.phone]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
}
