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
    
    
    // MARK: Credentials
    
    static func login(login: Login, role: Role) -> RequestConfig<MessageParser> {
        let request = LoginRequest(login: login, role: role)
        let parser = MessageParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func signUp(_ signUp: SignUp, role: Role) -> RequestConfig<MessageParser> {
        let request = SignUpRequest(signUp, role: role)
        let parser = MessageParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func changeUser(user: User) -> RequestConfig<SuccessParser> {
        let request = ChangeUserRequest(user: user)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func changeTariff(tariff: Tariff) -> RequestConfig<SuccessParser> {
        let request = ChangeTariffRequest(tariff: tariff)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    
    // MARK: Main
    
    static func users(text: String, limit: Int, offset: Int) -> RequestConfig<UsersParser> {
        let request = UsersRequest(text: text, limit: limit, offset: offset)
        let parser = UsersParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func user(username: String) -> RequestConfig<UserParser> {
        let request = UserRequest(username: username)
        let parser = UserParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func user(userID: Int, role: Role) -> RequestConfig<UserParser> {
        let request = UserRequest(userID: userID, role: role)
        let parser = UserParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func events(username: String, limit: Int, offset: Int) -> RequestConfig<EventsParser> {
        let request = EventsRequest(username: username, limit: limit, offset: offset)
        let parser = EventsParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func events(conferenceID: Int, limit: Int, offset: Int) -> RequestConfig<EventsParser> {
        let request = EventsRequest(conferenceID: conferenceID, limit: limit, offset: offset)
        let parser = EventsParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func events(parentEventID: Int, limit: Int, offset: Int) -> RequestConfig<EventsParser> {
        let request = EventsRequest(parentEventID: parentEventID, limit: limit, offset: offset)
        let parser = EventsParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func events(text: String, limit: Int, offset: Int) -> RequestConfig<EventsParser> {
        let request = EventsRequest(text: text, limit: limit, offset: offset)
        let parser = EventsParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func events(userID: Int, limit: Int, offset: Int, areActual: Bool) -> RequestConfig<EventsParser> {
        let request = EventsRequest(userID: userID, limit: limit, offset: offset, areActual: areActual)
        let parser = EventsParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func event(eventID: Int) -> RequestConfig<EventParser> {
        let request = EventRequest(eventID: eventID)
        let parser = EventParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func favoriteEvent(eventID: Int, userID: Int) -> RequestConfig<SuccessParser> {
        let request = FavoriteEventRequest(eventID: eventID, userID: userID)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func unfavoriteEvent(eventID: Int, userID: Int) -> RequestConfig<SuccessParser> {
        let request = UnfavoriteEventRequest(eventID: eventID, userID: userID)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }

    static func conferences(text: String, limit: Int, offset: Int) -> RequestConfig<ConferencesParser> {
        let request = ConferencesRequest(text: text, limit: limit, offset: offset)
        let parser = ConferencesParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func conferences(categoryID: Int, limit: Int, offset: Int) -> RequestConfig<ConferencesParser> {
        let request = ConferencesRequest(categoryID: categoryID, limit: limit, offset: offset)
        let parser = ConferencesParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func conferences(userID: Int, limit: Int, offset: Int) -> RequestConfig<ConferencesParser> {
        let request = ConferencesRequest(userID: userID, limit: limit, offset: offset)
        let parser = ConferencesParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func conferences(username: String, limit: Int, offset: Int) -> RequestConfig<ConferencesParser> {
        let request = ConferencesRequest(username: username, limit: limit, offset: offset)
        let parser = ConferencesParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func conferences(limit: Int, offset: Int) -> RequestConfig<ConferencesParser> {
        let request = ConferencesRequest(limit: limit, offset: offset)
        let parser = ConferencesParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func conference(conferenceID: Int) -> RequestConfig<ConferenceParser> {
        let request = ConferenceRequest(conferenceID: conferenceID)
        let parser = ConferenceParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func registerTicket(_ ticket: Ticket) -> RequestConfig<MessageParser> {
        let request = RegisterTicketRequest(ticket: ticket)
        let parser = MessageParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func ticket(ticketID: String) -> RequestConfig<TicketParser> {
        let request = TicketRequest(ticketID: ticketID)
        let parser = TicketParser()
               
        return .init(request: request, parser: parser)
    }
    
    
    // MARK: - Deletion
    
    static func deleteEvent(eventID: Int) -> RequestConfig<SuccessParser> {
        let request = DeleteEventRequest(eventID: eventID)
        let parser = SuccessParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func deleteConference(conferenceID: Int) -> RequestConfig<SuccessParser> {
        let request = DeleteConferencetRequest(conferenceID: conferenceID)
        let parser = SuccessParser()
               
        return .init(request: request, parser: parser)
    }
    
    static func deleteTariff(tariffID: Int) -> RequestConfig<SuccessParser> {
        let request = DeleteTariffRequest(tariffID: tariffID)
        let parser = SuccessParser()
               
        return .init(request: request, parser: parser)
    }
    
    
    // MARK: Organizer
    
    static func createConference(_ conference: Conference) -> RequestConfig<SuccessParser> {
        let request = CreateConferenceRequest(conference: conference)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func changeConference(_ conference: Conference) -> RequestConfig<SuccessParser> {
        let request = ChangeConferenceRequest(conference: conference)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func addToConference(events: [Event], conferenceID: Int) -> RequestConfig<SuccessParser> {
        let request = AddEventsRequest(events: events, conferenceID: conferenceID)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func addToConference(tariffs: [Tariff], conferenceID: Int) -> RequestConfig<SuccessParser> {
        let request = AddTariffsRequest(tariffs: tariffs, conferenceID: conferenceID)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func sendPushNotification(tariffID: Int,
                                     pushNotification: PushNotification) -> RequestConfig<SuccessParser> {
        let request = SendPushNotificationRequest(tariffID: tariffID, pushNotification: pushNotification)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func sendPushNotification(conferenceID: Int,
                                     pushNotification: PushNotification) -> RequestConfig<SuccessParser> {
        let request = SendPushNotificationRequest(conferenceID: conferenceID, pushNotification: pushNotification)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
    
    static func sendPushNotification(eventID: Int,
                                     pushNotification: PushNotification) -> RequestConfig<SuccessParser> {
        let request = SendPushNotificationRequest(eventID: eventID, pushNotification: pushNotification)
        let parser = SuccessParser()
        
        return .init(request: request, parser: parser)
    }
}
