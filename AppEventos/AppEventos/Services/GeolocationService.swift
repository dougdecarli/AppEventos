//
//  GeolocationMock.swift
//  AppEventos
//
//  Created by Douglas Immig on 28/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import RxSwift
import Contacts
import MapKit
import Social
import RxCocoa

protocol GeolocationProtocol {
    func getAddress(location: CLLocation) -> Observable<String?>
}

final class GeolocationService: GeolocationProtocol {
    
    private static var _instance: GeolocationService? = nil
    
    public static var sharedInstance: GeolocationService {
        get {
            if _instance == nil {
                _instance = GeolocationService()
            }
            
            return _instance!
        }
    }
    
    func getAddress(location: CLLocation) -> Observable<String?> {
        Observable.create { observable -> Disposable in
            CLGeocoder().reverseGeocodeLocation(location, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
                guard let place = clPlacemark?.first else {
                    observable.onNext(nil)
                    return
                }
                
                let postalAddressFormatter = CNPostalAddressFormatter()
                postalAddressFormatter.style = .mailingAddress
                
                if let postalAddress = place.postalAddress {
                    let addressString = "\(postalAddress.street), \(postalAddress.city)"
                    observable.onNext(addressString)
                }
                
                observable.onCompleted()
            }
            return Disposables.create{}
        }
    }
}

enum GeolocationServiceMockBehavior {
    case error
    case success
}

final class GeolocationMock: GeolocationProtocol {
    var behavior: GeolocationServiceMockBehavior
    
    init(behavior: GeolocationServiceMockBehavior) {
        self.behavior = behavior
    }
    
    func getAddress(location: CLLocation) -> Observable<String?> {
        switch behavior {
        case .success:
            return .just("example Street 1st, 21")
        case .error:
            return .just(nil)
        }
    }
}
