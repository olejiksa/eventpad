//
//  AddEventsRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 22.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class AddEventsRequest: BasePostRequest {
    
    init(events: [SimpleEvent], conferenceID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)org/addEventsToConference/\(conferenceID)"
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(events)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
}
