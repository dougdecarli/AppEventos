//
//  EventsTests.swift
//  AppEventos
//
//  Created by Douglas Immig on 28/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import AppEventos

class EventsTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var viewModel: EventsViewModel! = nil
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testOnSuccessEventsLoad() {
        self.viewModel = EventsViewModel(service: EventServiceMock(behavior: .success))
        
        let successObserver = scheduler.createObserver(ServiceMockDoubleBehavior.self)
        
        scheduler.createColdObservable([.next(100, ())])
            .bind(to: viewModel.allowLoadEvents)
            .disposed(by: disposeBag)
    
        viewModel.double.asDriver()
            .drive(successObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(successObserver.events, [.next(0, .none), .next(100, .success)])
    }
    
    func testOnErrorEventsLoad() {
        self.viewModel = EventsViewModel(service: EventServiceMock(behavior: .error))
        
        let errorObserver = scheduler.createObserver(ServiceMockDoubleBehavior.self)
        
        scheduler.createColdObservable([.next(100, ())])
            .bind(to: viewModel.allowLoadEvents)
            .disposed(by: disposeBag)
    
        viewModel.double.asDriver()
            .drive(errorObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(errorObserver.events, [.next(0, .none), .next(100, .error)])
    }
    
    
}

