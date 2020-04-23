//
//  UserRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class UserRequest: BaseGetRequest {
    
    init(username: String) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/info/\(username)"
        super.init(endpoint: endpoint)
    }
    
    init(userID: String) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/info/byId/\(userID)"
        super.init(endpoint: endpoint)
    }
}
