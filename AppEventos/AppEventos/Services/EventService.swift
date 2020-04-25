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

class EventService {
    
    private let apiUrl = "http://5b840ba5db24a100142dcd8c.mockapi.io/api/"
    
    func getEvents() -> Observable<[Event]> {
        let url = URL(string: "\(self.apiUrl)/events")!
        return Observable<[Event]>.create { (observable) -> Disposable in
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    observable.onError(error)
                }
                
                if let jsonData = data {
                    do {
                        let events = try JSONDecoder().decode(Array<Event>.self, from: jsonData)
                        observable.onNext(events)
                    } catch {
                        observable.onError(error)
                    }
                }
                observable.onCompleted()
            }
            task.resume()
            return Disposables.create{}
        }
    }
}
