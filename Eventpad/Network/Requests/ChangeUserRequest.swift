//
//  ChangeUserRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class ChangeUserRequest: BasePostRequest {
    
    init(user: User, role: Role) {
        let endpoint: String
        switch role {
        case .organizer:
            endpoint = "\(RequestFactory.endpointRoot)org/change/\(user.username)"
            
        case .participant:
            endpoint = "\(RequestFactory.endpointRoot)usr/change/\(user.username)"
            
        default:
            fatalError()
        }
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(user)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
    
    override var urlRequest: URLRequest? {
        var request = super.urlRequest
        guard let accessToken = Global.accessToken else { return request }
        request?.setValue(accessToken, forHTTPHeaderField: "token")
        return request
    }
}
