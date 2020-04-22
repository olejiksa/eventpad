//
//  CreateConferenceRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 22.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class CreateConferenceRequest: BasePostRequest {
    
    init(conference: Conference) {
        let endpoint = "\(RequestFactory.endpointRoot)org/createConference"
        let parameters = ["name": conference.title,
                          "description": conference.description,
                          "category": conference.category,
                          "location": conference.location,
                          "date_start": conference.dateStart,
                          "date_end": conference.dateEnd,
                          "is_cancelled": conference.isCancelled,
                          "organizer_login": conference.organizerLogin] as [String: Any]
        
        super.init(endpoint: endpoint, parameters: parameters)
    }
}
