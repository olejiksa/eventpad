//
//  ChangeRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class ChangeRequest: BasePostRequest {
    
    init(event: Event) {
        let endpoint = "\(RequestFactory.endpointRoot)org/changeEvent/\(event.id!)"
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(event)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
    
    init(conference: Conference) {
        let endpoint = "\(RequestFactory.endpointRoot)org/changeConference/\(conference.id!)"
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(conference)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
    
    init(tariff: Tariff) {
        let endpoint = "\(RequestFactory.endpointRoot)org/changeTariff/\(tariff.id!)"
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(tariff)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
    
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
