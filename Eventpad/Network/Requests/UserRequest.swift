//
//  UserRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class UserRequest: BaseGetRequest {
    
    init(username: String, role: Role) {
        let endpoint: String
        switch role {
        case .organizer:
            endpoint = "\(RequestFactory.endpointRoot)org/info/\(username)"
            
        case .participant:
            endpoint = "\(RequestFactory.endpointRoot)usr/info/\(username)"
            
        default:
            fatalError()
        }
        
        super.init(endpoint: endpoint)
    }
    
    init(userID: Int, role: Role) {
        let endpoint: String
        switch role {
        case .organizer:
            endpoint = "\(RequestFactory.endpointRoot)org/info/byId/\(userID)"
            
        case .participant:
            endpoint = "\(RequestFactory.endpointRoot)usr/info/byId/\(userID)"
            
        default:
            fatalError()
        }
        
        super.init(endpoint: endpoint)
    }
}
