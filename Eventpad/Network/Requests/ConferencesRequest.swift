//
//  ConferencesRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class ConferencesRequest: BaseGetRequest {
    
    init(text: String, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/searchConferences/\(text)"
        let parameters = ["pageSize": limit, "pageNumber": offset]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(categoryID: Int, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/findConferencesByCategory/\(categoryID)"
        let parameters = ["pageSize": limit, "pageNumber": offset]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(userID: Int, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/personal/getConferences/\(userID)"
        let parameters = ["limit": limit, "offset": offset]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(username: String, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)org/conferences/\(username)"
        let parameters = ["limit": limit, "offset": offset]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    init(limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/getAllConferences"
        let parameters = ["limit": limit, "offset": offset]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
    
    override var urlRequest: URLRequest? {
        var request = super.urlRequest
        guard let accessToken = Global.accessToken else { return request }
        request?.setValue(accessToken, forHTTPHeaderField: "token")
        return request
    }
}
