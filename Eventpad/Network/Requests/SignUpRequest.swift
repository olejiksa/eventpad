//
//  SignUpRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class SignUpRequest: BasePostRequest {
    
    init(_ signUp: SignUp, role: Role) {
        let endpoint: String
        switch role {
        case .organizer:
            endpoint = "\(RequestFactory.endpointRoot)reg/organizer"
            
        case .participant:
            endpoint = "\(RequestFactory.endpointRoot)reg/user"
        }
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(signUp)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
}
