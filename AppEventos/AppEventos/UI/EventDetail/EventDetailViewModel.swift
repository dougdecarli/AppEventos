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
    var eventService: EventService!
    var shareContent = BehaviorRelay<ShareLinkContent?>(value: nil)
    var navigationController: UINavigationController!
    let activityData = ActivityData()

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
    init(event: Event, service: EventService, navigationController: UINavigationController) {
        self.event = BehaviorRelay<Event>(value: event)
        self.eventService = service
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
            .flatMap(eventService.checkin(event:))
            .do(onNext: { _ in
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
        getImageFromUrl(url: event.value.image)
            .map { $0 }
            .asDriver(onErrorJustReturn: UIImage())
    }
    
    private func setupEventTitleDriver() -> Driver<String> {
        return Driver.just(event.value.title)
    }
    
    private func setupEventDateDriver() -> Driver<String> {
        let date = Date.getDateFormatter(timestamp: event.value.date)
        return Driver.just(date)
    }
    
    private func setupEventAddressDriver() -> Driver<String> {
        getEventAddress(location: eventLocation ?? CLLocation()).asObservable()
            .map { $0 }
            .asDriver(onErrorJustReturn: "")
    }
    
    private func setupEventDescriptionDriver() -> Driver<String> {
        return Driver.just(event.value.description)
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
        let eventLatitude = event.value.latitude
        let eventLongitude = event.value.longitude
        eventLocation = CLLocation(latitude: eventLatitude, longitude: eventLongitude)
        coordinates = BehaviorRelay<CLLocationCoordinate2D>(value: (CLLocationCoordinate2D(latitude: eventLatitude, longitude: eventLongitude)))
        coordinateRegion = BehaviorRelay<MKCoordinateRegion>(value: (MKCoordinateRegion(center: coordinates.value,
                                                                                        span: MKCoordinateSpan(latitudeDelta: 0.05,
                                                                                                               longitudeDelta: 0.05))))
    }
    
    private func getEventAddress(location: CLLocation) -> Observable<String> {
        Observable.create { observable -> Disposable in
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityData)
            CLGeocoder().reverseGeocodeLocation(location, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                var addressString: String = "Não foi possível recuperar o endereço"
                guard let place = clPlacemark?.first else {
                    observable.onNext(addressString)
                    return
                }
                
                let postalAddressFormatter = CNPostalAddressFormatter()
                postalAddressFormatter.style = .mailingAddress
                
                if let postalAddress = place.postalAddress {
                    addressString = "\(postalAddress.street), \(postalAddress.city)"
                    observable.onNext(addressString)
                }
                
                observable.onNext(addressString)
                observable.onCompleted()
            }
            return Disposables.create{}
        }
    }
    
    private func onShareButtonTouched() {
        let imageURL = URL(string: event.value.image)!
        let share = ShareLinkContent()
        share.contentURL = imageURL
        share.quote = event.value.title
        shareContent.accept(share)
    }
}


