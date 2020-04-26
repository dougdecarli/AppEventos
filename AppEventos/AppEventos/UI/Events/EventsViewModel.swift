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
    private var events = BehaviorRelay<[Event]>(value: [Event]())
    private let eventService = EventService()
    var catchedError = BehaviorRelay<Bool>(value: false)
    var onTryAgainButtonTouched = PublishRelay<Void>()
    var navigationController: UINavigationController!
    let activityData = ActivityData()

    // MARK: - cell items
    private var eventItems: [EventCells] = []
    
    // MARK: - viewModels
    private var eventViewModel = BehaviorRelay<EventCellViewModel?>(value: nil)
    
    // MARK: - cells
    private var eventCell: EventCells!
    
    init() {
        setupEventCellObservable()
        setupOnTryAgainButtonTouched()
        loadEvents()
    }
    
    private func setupEventCellObservable() {
        events.asObservable()
            .skip(1)
            .flatMap(loadCells(events:))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func loadCells(events: [Event]) -> Observable<Void> {
        Observable.create { [weak self] observable -> Disposable in
            for event in events {
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
    
    private func loadEvents() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        eventService.getEvents()
            .subscribe(onNext: { [weak self] (model) in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self?.catchedError.accept(false)
                self?.events.accept(model)
            }, onError: { [weak self] (error) in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self?.catchedError.accept(true)
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
                                                   service: eventService,
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
