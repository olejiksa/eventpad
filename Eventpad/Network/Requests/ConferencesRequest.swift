//
//  ConferencesRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class ConferencesRequest: BaseGetRequest {
    
    init(text: String, limit: Int, offset: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/searchConferences/\(text)"
        let parameters = ["pageSize": limit, "pageNumber": offset]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
}
