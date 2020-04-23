//
//  FavoriteEventRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class FavoriteEventRequest: BasePostRequest {
    
    init(eventID: Int, userID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/addEvent/\(userID)?eventId=\(eventID)"
        super.init(endpoint: endpoint)
    }
}
