//
//  SendPushNotificationRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 13.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class SendPushNotificationRequest: BasePostRequest {
    
    init(tariffID: Int, pushNotification: PushNotification) {
        let endpoint = "\(RequestFactory.endpointRoot)org/sendPushNotifications/tariff/\(tariffID)"
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(pushNotification)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
    
    init(eventID: Int, pushNotification: PushNotification) {
        let endpoint = "\(RequestFactory.endpointRoot)org/sendPushNotifications/event/\(eventID)"
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(pushNotification)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
    
    init(conferenceID: Int, pushNotification: PushNotification) {
        let endpoint = "\(RequestFactory.endpointRoot)org/sendPushNotifications/event/\(conferenceID)"
        do {
            let jsonEncoder = JSONEncoder()
            let encodedJson = try jsonEncoder.encode(pushNotification)
            guard let parameters = try JSONSerialization.jsonObject(with: encodedJson) as? [String: Any] else {
                fatalError()
            }
            
            super.init(endpoint: endpoint, parameters: parameters)
        } catch {
            fatalError()
        }
    }
    
    override var urlRequest: URLRequest? {
        var request = super.urlRequest
        guard let accessToken = Global.accessToken else { return request }
        request?.setValue(accessToken, forHTTPHeaderField: "token")
        return request
    }
}
