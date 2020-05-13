//
//  EventsRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class EventsRequest: BaseGetRequest {
    
    init(username: String, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/eventsWhereSpeaker/\(username)"
        let parameters = ["limit": limit, "offset": offset]
            
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(conferenceID: Int, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/conferenceEvents/\(conferenceID)"
        let parameters = ["limit": limit, "offset": offset]
            
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(parentEventID: Int, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/childrenEvents/\(parentEventID)"
        let parameters = ["limit": limit, "offset": offset]
            
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(text: String, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/searchEvents/\(text)"
        let parameters = ["pageSize": limit, "pageNumber": offset]
            
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(userID: Int, limit: Int, offset: Int, areActual: Bool) {
        let endpoint: String
        let parameters = ["limit": limit, "offset": offset]

        if areActual {
            endpoint = "\(RequestFactory.endpointRoot)usr/personal/getActualPersonalEvents/\(userID)"
        } else {
            endpoint = "\(RequestFactory.endpointRoot)usr/personal/getPersonalEvents/\(userID)"
        }
            
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    override var urlRequest: URLRequest? {
        var request = super.urlRequest
        guard let accessToken = Global.accessToken else { return request }
        request?.setValue(accessToken, forHTTPHeaderField: "token")
        return request
    }
}
