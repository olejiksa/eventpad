//
//  EventRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class EventRequest: BaseGetRequest {
    
    init(eventID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/event/\(eventID)"
        super.init(endpoint: endpoint)
    }
}
