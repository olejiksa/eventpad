//
//  UnfavoriteEventRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class UnfavoriteEventRequest: BasePostRequest {
    
    init(eventID: Int, userID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/deleteEvent/\(userID)"
        let parameters = ["eventId": eventID]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
}
