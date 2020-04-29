//
//  EventsDetailTests.swift
//  AppEventos
//
//  Created by Douglas Immig on 28/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import XCTest
import RxTest
import MapKit
import RxSwift
import RxCocoa
@testable import AppEventos

class EventsDetailTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var viewModel: EventDetailViewModel! = nil
    var input: EventDetailViewModel.Input! = nil
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        self.input = EventDetailViewModel.Input(onBackButtonTouched: PublishRelay<Void>(), onRightButtonTouched: PublishRelay<Void>(), onLeftButtonTouched: PublishRelay<Void>())
    }
    
    func testOnSuccessCheckin() {
        self.viewModel = EventDetailViewModel(event: Event.eventMock(), eventsService: EventServiceMock(behavior: .success), navigationController: UINavigationController())
        let _ = viewModel.transform(input: input)
        let successObserver = scheduler.createObserver(ServiceMockDoubleBehavior.self)
        
        let _ = scheduler.createHotObservable([next(100, ())])
            .bind(to: self.input.onRightButtonTouched)
            .disposed(by: disposeBag)
        
        viewModel.checkinDouble.asDriver()
            .drive(successObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(successObserver.events, [.next(0, .none), .next(100, .success)])
    }
    
    func testOnErrorCheckin() {
        self.viewModel = EventDetailViewModel(event: Event.eventMock(), eventsService: EventServiceMock(behavior: .error), navigationController: UINavigationController())
        let _ = viewModel.transform(input: input)
        
        let errorObserver = scheduler.createObserver(ServiceMockDoubleBehavior.self)
        
        let _ = scheduler.createHotObservable([next(100, ())])
            .bind(to: self.input.onRightButtonTouched)
            .disposed(by: disposeBag)
        
        viewModel.checkinDouble.asDriver()
            .drive(errorObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(errorObserver.events, [.next(0, .none), .next(100, .error)])
    }
    
    func testOnSuccessGetAddress() {
        self.viewModel = EventDetailViewModel(event: Event.eventMock(), geoService: GeolocationMock(behavior: .success), navigationController: UINavigationController())
        let vc = EventDetailViewController(viewModel: viewModel)
        let successObserver = scheduler.createObserver(ServiceMockDoubleBehavior.self)
        vc.bind()
        
        viewModel.geolocationDouble.asDriver()
            .drive(successObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(successObserver.events, [.next(0, .success)])
    }
    
    func testErrorOnGetAddress() {
        self.viewModel = EventDetailViewModel(event: Event.eventMock(), geoService: GeolocationMock(behavior: .error), navigationController: UINavigationController())
        let vc = EventDetailViewController(viewModel: viewModel)
        let errorObserver = scheduler.createObserver(ServiceMockDoubleBehavior.self)
        vc.bind()
        
        viewModel.geolocationDouble.asDriver()
            .drive(errorObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(errorObserver.events, [.next(0, .error)])
    }
    
    
}
