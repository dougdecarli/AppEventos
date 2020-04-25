//
//  EventCellViewModel.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class EventCellViewModel {
    
    private let disposeBag = DisposeBag()
    let title: BehaviorRelay<String>
    let price: BehaviorRelay<String>
    let month: BehaviorRelay<String>
    let day: BehaviorRelay<String>
    let image: BehaviorRelay<UIImage>
    var didPressed: PublishSubject<Any?> = PublishSubject<Any?>()
    
    init(event: Event) {
        self.title = BehaviorRelay<String>.init(value: event.title)
        self.price = BehaviorRelay<String>.init(value: "R$ \(event.price)")
        self.month = BehaviorRelay<String>.init(value: Date.getMonth(timestamp: event.date))
        self.day = BehaviorRelay<String>.init(value: Date.getDay(timestamp: event.date))
        self.image = BehaviorRelay<UIImage>.init(value: UIImage())
    }
}

extension EventCellViewModel {
    var titleObservable: Observable<String> {
        return title.asObservable()
    }
    
    var priceObservable: Observable<String> {
        return price.asObservable()
    }
    
    var monthObservable: Observable<String> {
        return month.asObservable()
    }
    
    var dayObservable: Observable<String> {
        return day.asObservable()
    }
    
    var imageObservable: Observable<UIImage> {
        return image.asObservable()
    }
}
