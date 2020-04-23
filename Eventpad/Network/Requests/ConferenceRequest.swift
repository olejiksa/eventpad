//
//  ConferenceRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class ConferenceRequest: BaseGetRequest {
    
    init(conferenceID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/conference/\(conferenceID)"
        super.init(endpoint: endpoint)
    }
}
