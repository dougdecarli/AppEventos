//
//  EventDetailViewModel.swift
//  AppEventos
//
//  Created by Douglas Immig on 25/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import RxSwift
import Contacts
import MapKit
import Social
import RxCocoa
import FBSDKShareKit
import FBSDKCoreKit
import NVActivityIndicatorView

class EventDetailViewModel: NVActivityIndicatorViewable {
    private let disposeBag = DisposeBag()
    var event: BehaviorRelay<Event>
    private var eventLocation: CLLocation? = nil
    var coordinateRegion: BehaviorRelay<MKCoordinateRegion>!
    var coordinates: BehaviorRelay<CLLocationCoordinate2D>!
    var didCheckinWithSuccess = BehaviorRelay<Bool>(value: false)
    var onViewDidLoad = PublishRelay<Void>()
    private var eventsService: EventServiceProtocol
    private var geoService: GeolocationProtocol
    var shareContent = BehaviorRelay<ShareLinkContent?>(value: nil)
    var navigationController: UINavigationController!
    let activityData = ActivityData()
    var checkinDouble = BehaviorRelay<ServiceMockDoubleBehavior>(value: .none)
    var geolocationDouble = BehaviorRelay<ServiceMockDoubleBehavior>(value: .none)

    struct Input {
        let onBackButtonTouched: PublishRelay<Void>
        let onRightButtonTouched: PublishRelay<Void>
        let onLeftButtonTouched: PublishRelay<Void>
    }
    
    struct Output {
        let eventImageDriver: Driver<UIImage>
        let eventTitleDriver: Driver<String>
        let eventDateDriver: Driver<String>
        let eventAddressDriver: Driver<String>
        let eventDescriptionDriver: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        setupCoordinates()
        
        setupOnBackButtonTouched(input.onBackButtonTouched)
        setupOnRightButtonTouched(input.onRightButtonTouched)
        setupOnLeftButtonTouched(input.onLeftButtonTouched)
        
        let eventImageDriver = setupEventImageDriver()
        let eventTitleDriver = setupEventTitleDriver()
        let eventDateDriver = setupEventDateDriver()
        let eventAddressDriver = setupEventAddressDriver()
        let eventDescriptionDriver = setupEventDescriptionDriver()
        
        return Output(
            eventImageDriver: eventImageDriver,
            eventTitleDriver: eventTitleDriver,
            eventDateDriver: eventDateDriver,
            eventAddressDriver: eventAddressDriver,
            eventDescriptionDriver: eventDescriptionDriver
        )
    }
    
    //MARK: - Init
    init(event: Event,
         eventsService: EventServiceProtocol = EventService.sharedInstance,
         geoService: GeolocationProtocol = GeolocationService.sharedInstance,
         navigationController: UINavigationController) {
        self.event = BehaviorRelay<Event>(value: event)
        self.eventsService = eventsService
        self.geoService = geoService
        self.navigationController = navigationController
    }
    
    //MARK: - Inputs
    private func setupOnBackButtonTouched(_ onBackButtonTouched: PublishRelay<Void>) {
        onBackButtonTouched.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func setupOnRightButtonTouched(_ onRightButtonTouched: PublishRelay<Void>) {
        onRightButtonTouched.asObservable()
            .do(onNext: { [weak self] _ in
                NVActivityIndicatorPresenter.sharedInstance.startAnimating(self?.activityData ?? ActivityData())
            })
            .withLatestFrom(event)
            .flatMap(eventsService.checkin(event:))
            .do(onNext: { (success) in
                success ? self.checkinDouble.accept(.success) : self.checkinDouble.accept(.error)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            })
            .bind(to: didCheckinWithSuccess)
            .disposed(by: disposeBag)
    }
    
    private func setupOnLeftButtonTouched(_ onLeftButtonTouched: PublishRelay<Void>) {
        onLeftButtonTouched.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.onShareButtonTouched()
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Outputs
    private func setupEventImageDriver() -> Driver<UIImage> {
        getImageFromUrl(url: event.value.image ?? "")
            .map { $0 }
            .asDriver(onErrorJustReturn: UIImage())
    }
    
    private func setupEventTitleDriver() -> Driver<String> {
        return Driver.just(event.value.title ?? "")
    }
    
    private func setupEventDateDriver() -> Driver<String> {
        let date = Date.getDateFormatter(timestamp: event.value.date ?? 0.0)
        return Driver.just(date)
    }
    
    func setupEventAddressDriver() -> Driver<String> {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityData)
        return geoService.getAddress(location: eventLocation ?? CLLocation())
            .do(onNext: { [weak self] (res) in
                let response = res as String?
                response == nil ? self?.geolocationDouble.accept(.error) : self?.geolocationDouble.accept(.success)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            })
            .map { $0 ?? "Não foi possível recuperar o endereço" }
            .asDriver(onErrorJustReturn: "")
    }
    
    private func setupEventDescriptionDriver() -> Driver<String> {
        return Driver.just(event.value.description ?? "")
    }

    //MARK: - Action and auxiliar funcs
    private func getImageFromUrl(url: String) -> Observable<UIImage> {
        Observable.create { (observable) -> Disposable in
            if let url = URL(string: url),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                observable.onNext(image)
            } else {
                observable.onNext(UIImage(named: "generic-image") ?? UIImage())
            }
            return Disposables.create {}
        }
    }
    
    private func setupCoordinates() {
        let eventLatitude = event.value.latitude ?? 0.0
        let eventLongitude = event.value.longitude ?? 0.0
        eventLocation = CLLocation(latitude: eventLatitude, longitude: eventLongitude)
        coordinates = BehaviorRelay<CLLocationCoordinate2D>(value: (CLLocationCoordinate2D(latitude: eventLatitude, longitude: eventLongitude)))
        coordinateRegion = BehaviorRelay<MKCoordinateRegion>(value: (MKCoordinateRegion(center: coordinates.value,
                                                                                        span: MKCoordinateSpan(latitudeDelta: 0.05,
                                                                                                               longitudeDelta: 0.05))))
    }
    
    private func onShareButtonTouched() {
        let imageURL = URL(string: event.value.image ?? "")!
        let share = ShareLinkContent()
        share.contentURL = imageURL
        share.quote = event.value.title
        shareContent.accept(share)
    }
}


