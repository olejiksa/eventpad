//
//  TicketRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

final class TicketRequest: BaseGetRequest {
    
    init(ticketID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)usr/ticket/\(ticketID)"
        super.init(endpoint: endpoint)
    }
}

