//
//  RequestFactory.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct RequestFactory {
    
    // MARK: Endpoints
    
    static let endpointTerms = "https://vk.com/@hseapp-terms"
    static let endpointPrivacy = "https://vk.com/@hseapp-privacy"
    static let endpointRoot = "http://54.93.249.91:8080/api/"
    
    
    // MARK: - Credentials
    
    static func login(username: String,
                      password: String,
                      deviceName: String) -> RequestConfig<LoginParser> {
        let request = LoginRequest(username: username,
                                   password: password,
                                   deviceName: deviceName)
        let parser = LoginParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func signUp(_ signUp: SignUp) -> RequestConfig<LoginParser> {
        let request = SignUpRequest(signUp)
        let parser = LoginParser()
        
        return .init(request: request, parser: parser)
    }
    
    
    // MARK: - Main
    
    static func user(username: String) -> RequestConfig<UserParser> {
        let request = UserRequest(username: username)
        let parser = UserParser()
        
        return .init(request: request, parser: parser)
    }
    
    
    // MARK: - Organizer
    
    static func createConference(_ conference: Conference) -> RequestConfig<SuccessParser> {
        let request = CreateConferenceRequest(conference: conference)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func addToConference(events: [SimpleEvent], conferenceID: Int) -> RequestConfig<SuccessParser> {
        let request = AddEventsRequest(events: events, conferenceID: conferenceID)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func addToConference(tariffs: [Tariff], conferenceID: Int) -> RequestConfig<SuccessParser> {
        let request = AddTariffsRequest(tariffs: tariffs, conferenceID: conferenceID)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
}
