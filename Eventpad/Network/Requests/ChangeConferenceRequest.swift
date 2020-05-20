//
//  ChangeConferenceRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class ChangeConferenceRequest: BasePostRequest {
    
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
    
    override var urlRequest: URLRequest? {
        var request = super.urlRequest
        guard let accessToken = Global.accessToken else { return request }
        request?.setValue(accessToken, forHTTPHeaderField: "token")
        return request
    }
}
