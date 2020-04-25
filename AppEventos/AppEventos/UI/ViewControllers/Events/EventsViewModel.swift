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

enum EventSectionsName: String, CaseIterable {
    case events = "EVENTOS"
}

class EventsViewModel {
    
    private let disposeBag = DisposeBag()
    var data: BehaviorRelay<[EventSectionModel]> = BehaviorRelay<[EventSectionModel]>(value: [])
    private var events = BehaviorRelay<[Event]>(value: [Event]())
    private let eventService = EventService()
    private var catchedError = BehaviorRelay<Bool>(value: false)

    // MARK: - cell items
    private var eventItems: [EventCells] = []
    
    // MARK: - viewModels
    private var eventViewModel: EventCellViewModel?
    
    // MARK: - cells
    private var eventCell: EventCells?
    
    init() {
        setupEventCell()
        loadEvents()
    }
    
    private func setupEventCell() {
        events.asObservable()
            .skip(1)
            .flatMap(loadCells(events:))
            .subscribe()
            .disposed(by: disposeBag)
        
        self.eventViewModel?.didPressed
        .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.onCellTouched()
            }).disposed(by: disposeBag)
    }
    
    private func loadCells(events: [Event]) -> Observable<Void> {
        Observable.create { [weak self] observable -> Disposable in
            for event in events {
                self?.eventViewModel = EventCellViewModel(event: event)
                self?.eventCell = EventCells.EventCell(viewModel: (self?.eventViewModel!)!)
                self?.eventItems.append((self?.eventCell)!)
            }
            self?.setupModels()
            observable.onCompleted()
            return Disposables.create {}
        }
    }
    
    private func loadEvents() {
        eventService.getEvents()
            .subscribe(onNext: { [weak self] (model) in
                self?.events.accept(model)
            }, onError: { [weak self] (error) in
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
    
    private func onCellTouched() {
        
    }
}
