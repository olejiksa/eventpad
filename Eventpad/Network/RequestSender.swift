//
//  RequestSender.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

protocol RequestSenderProtocol {
    
    func send<Parser>(config: RequestConfig<Parser>,
                     completion: @escaping (Result<Parser.Model, Error>) -> ())
}

final class RequestSender: RequestSenderProtocol {
    
    private let session = URLSession(configuration: .default)
    private let userDefaultsService = UserDefaultsService()
    
    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "HTTP Requests Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init() {}
    
    func send<Parser>(config: RequestConfig<Parser>,
                      completion: @escaping (Result<Parser.Model, Error>) -> ()) where Parser: ParserProtocol {
        guard let urlRequest = config.request.urlRequest else {
            DispatchQueue.main.async {
                completion(.failure(ParserError.urlParserError))
            }
            
            return
        }
        
        let operation = BlockOperation { [weak self] in
            guard let self = self else { return }
            
            self.session.dataTask(with: urlRequest) { data, response, error in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    let statusCode = HttpStatusCode(rawValue: httpResponse.statusCode)
                else { return }
                
                switch statusCode {
                case .ok, .badRequest:
                    break
                    
                default:
                    DispatchQueue.main.async {
                        completion(.failure(ResponseError(statusCode)))
                    }
                    
                    return
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    
                    return
                }
                
//                if let data = data {
//                    print(String(data: data, encoding: .utf8) ?? "")
//                }
                
                guard
                    let data = data,
                    let parsedModel: Parser.Model = config.parser.parse(data: data)
                else {
                    DispatchQueue.main.async {
                        completion(.failure(ParserError.dataParserError))
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(parsedModel))
                }
            }.resume()
        }
        
        queue.addOperation(operation)
    }
}

