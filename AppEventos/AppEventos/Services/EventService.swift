//
//  EventService.swift
//  AppEventos
//
//  Created by Douglas Immig on 25/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

protocol EventServiceProtocol {
    func getEvents() -> Observable<[Event?]>
    func checkin(event: Event?) -> Observable<Bool>
}

class EventService: EventServiceProtocol {
    
    private let apiUrl = "http://5b840ba5db24a100142dcd8c.mockapi.io/api/"
    
    private static var _instance: EventService? = nil
    
    public static var sharedInstance: EventService {
        get {
            if _instance == nil {
                _instance = EventService()
            }
            
            return _instance!
        }
    }
    
    func getEvents() -> Observable<[Event?]> {
        let url = URL(string: "\(self.apiUrl)/events")!
        return Observable<[Event?]>.create { (observable) -> Disposable in
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    observable.onNext([nil])
                }
                
                if let jsonData = data {
                    do {
                        let events = try JSONDecoder().decode(Array<Event>.self, from: jsonData)
                        observable.onNext(events)
                    } catch {
                        observable.onNext([nil])
                    }
                }
                observable.onCompleted()
            }
            task.resume()
            return Disposables.create{}
        }
    }
    
    func checkin(event: Event?) -> Observable<Bool> {
        return Observable<Bool>.create { (observable) -> Disposable in
            let url = URL(string: "\(self.apiUrl)/checkin")!
            let params = ["eventId": event?.id, "name": event?.people[0].name, "email": "example@example.com"] as Dictionary<String, AnyObject>
            let request : NSMutableURLRequest = NSMutableURLRequest()
            request.url = url
            request.httpMethod = "POST"
            request.httpBody  = try! JSONSerialization.data(withJSONObject: params, options: [])
            let configuration = URLSessionConfiguration .default
            let session = URLSession(configuration: configuration)
            
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                if error != nil {
                    observable.onNext(false)
                } else {
                    observable.onNext(true)
                }
                observable.onCompleted()
            }
            task.resume()
            return Disposables.create{}
        }
    }
}

enum EventServiceMockBehavior {
    case error
    case success
}

final class EventServiceMock: EventServiceProtocol {
    
    var behavior: EventServiceMockBehavior
    
    init(behavior: EventServiceMockBehavior) {
        self.behavior = behavior
    }
    
    func getEvents() -> Observable<[Event?]> {
        switch behavior {
        case .success:
            return .just([.eventMock()])
        case .error:
            return .just([nil])
        }
    }
    
    func checkin(event: Event?) -> Observable<Bool> {
        switch behavior {
        case .success:
            return .just(true)
        case .error:
            return .just(false)
        }
    }
}
