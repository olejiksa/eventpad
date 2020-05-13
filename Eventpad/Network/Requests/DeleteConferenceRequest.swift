//
//  DeleteConferenceRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 13.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class DeleteConferencetRequest: BaseDeleteRequest {
    
    init(conferenceID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)org/deleteConference/\(conferenceID)"
        super.init(endpoint: endpoint)
    }
    
    override var urlRequest: URLRequest? {
        var request = super.urlRequest
        guard let accessToken = Global.accessToken else { return request }
        request?.setValue(accessToken, forHTTPHeaderField: "token")
        return request
    }
}
