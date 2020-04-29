//
//  EventsViewModel.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import NVActivityIndicatorView

enum EventSectionsName: String, CaseIterable {
    case events = "EVENTOS"
}

class EventsViewModel: NVActivityIndicatorViewable {
    
    private let disposeBag = DisposeBag()
    var data: BehaviorRelay<[EventSectionModel]> = BehaviorRelay<[EventSectionModel]>(value: [])
    private var events = BehaviorRelay<[Event?]>(value: [Event?]())
    var catchedError = BehaviorRelay<Bool>(value: false)
    var onTryAgainButtonTouched = PublishRelay<Void>()
    var navigationController: UINavigationController!
    let activityData = ActivityData()
    let allowLoadEvents = PublishRelay<Void>()
    
    private var service: EventServiceProtocol
    var double = BehaviorRelay<ServiceMockDoubleBehavior>(value: .none)

    // MARK: - cell items
    private var eventItems: [EventCells] = []
    
    // MARK: - viewModels
    private var eventViewModel = BehaviorRelay<EventCellViewModel?>(value: nil)
    
    // MARK: - cells
    private var eventCell: EventCells!
    
    init(service: EventServiceProtocol = EventService.sharedInstance) {
        self.service = service
        setupViewModel()
    }
    
    func setupViewModel() {
        allowLoadEvents.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.setupEventCellObservable()
                self?.setupOnTryAgainButtonTouched()
                self?.loadEvents()
            }).disposed(by: disposeBag)
    }
    
    private func setupEventCellObservable() {
        events.asObservable()
            .skip(1)
            .flatMap(loadCells(events:))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func loadCells(events: [Event?]) -> Observable<Void> {
        Observable.create { [weak self] observable -> Disposable in
            for event in events {
                guard let event = event else { return Disposables.create {} }
                self?.setupCell(event: event)
            }
            self?.setupModels()
            observable.onCompleted()
            return Disposables.create {}
        }
    }
    
    private func setupCell(event: Event) {
        self.eventViewModel.accept(EventCellViewModel(event: event))
        self.eventCell = EventCells.EventCell(viewModel: (self.eventViewModel.value!))
        self.eventItems.append((self.eventCell)!)
        
        self.eventViewModel.value?.didPressed
        .asObservable()
            .subscribe(onNext: { [weak self] (viewModel) in
                self?.onCellTouched(viewModel!)
            }).disposed(by: disposeBag)
    }
    
    func loadEvents() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        service.getEvents()
            .subscribe(onNext: { [weak self] (model) in
                if let model = model as? [Event] {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self?.double.accept(.success)
                    self?.catchedError.accept(false)
                    self?.events.accept(model)
                } else {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self?.double.accept(.error)
                    self?.catchedError.accept(true)
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupModels() {
        data.accept( EventSectionsName.allCases.compactMap { (section) -> EventSectionModel in
            switch section {
            case .events:
                return EventSectionModel.Event(title: section.rawValue,
                                               items: eventItems)
            }
        })
    }
    
    private func onCellTouched(_ cellViewModel: EventCellViewModel) {
        let detailViewModel = EventDetailViewModel(event: cellViewModel.event.value,
                                                   eventsService: service as! EventService,
                                                   navigationController: navigationController)
        let detailVC = EventDetailViewController(viewModel: detailViewModel)
        self.navigationController.pushViewController(detailVC, animated: true)
    }
    
    private func setupOnTryAgainButtonTouched() {
        onTryAgainButtonTouched.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.loadEvents()
            }).disposed(by: disposeBag)
    }
}

