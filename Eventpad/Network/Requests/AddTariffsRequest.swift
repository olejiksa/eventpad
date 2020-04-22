//
//  AddTariffsRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 22.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class AddTariffsRequest: BasePostRequest {
    
    init(tariffs: [Tariff], conferenceID: Int) {
        let endpoint = "\(RequestFactory.endpointRoot)org/addTariffsToConference/\(conferenceID)"
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(tariffs)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
}
