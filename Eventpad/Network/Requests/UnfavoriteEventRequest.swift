//
//  UnfavoriteEventRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class UnfavoriteEventRequest: BasePostRequest {
    
    init(eventID: Int, userID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/deleteEvent/\(userID)?eventId=\(eventID)"
        super.init(endpoint: endpoint)
    }
    
    override var urlRequest: URLRequest? {
        var request = super.urlRequest
        guard let accessToken = Global.accessToken else { return request }
        request?.setValue(accessToken, forHTTPHeaderField: "token")
        return request
    }
}
