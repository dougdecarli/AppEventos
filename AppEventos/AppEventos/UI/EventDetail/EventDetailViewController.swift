//
//  EventDetailViewController.swift
//  AppEventos
//
//  Created by Douglas Immig on 25/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit
import MapKit
import ExpandableLabel
import RxSwift
import RxCocoa
import FBSDKShareKit
import FBSDKCoreKit

class EventDetailViewController: UIViewController {
    
    typealias CustomView = EventDetailView
    typealias ViewModel = EventDetailViewModel
    let customView = CustomView()
    
    // MARK:- Private Variables
    private let disposeBag = DisposeBag()
    private let onBackButtonTouched = PublishRelay<Void>()
    private let onRightButtonTouched = PublishRelay<Void>()
    private let onLeftButtonTouched = PublishRelay<Void>()
    private var eventLocation: CLLocation? = nil
    
    // MARK: - ViewModel
    var viewModel: ViewModel!
    lazy var viewModelOutput: ViewModel.Output = {
        let input = ViewModel.Input(onBackButtonTouched: onBackButtonTouched,
                                    onRightButtonTouched: onRightButtonTouched,
                                    onLeftButtonTouched: onLeftButtonTouched)
        
        return viewModel.transform(input: input)
    }()
    
    // MARK:- Init
    init(viewModel: ViewModel){
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        bindInputs()
        bindOutputs()
    }
    
    private func bindInputs() {
        customView
            .backButton.rx.tap
            .bind(to: onBackButtonTouched)
            .disposed(by: disposeBag)
        
        customView
            .checkinButtons.rigthButton.rx.tap
            .bind(to: onRightButtonTouched)
            .disposed(by: disposeBag)
        
        customView
            .checkinButtons.leftButton.rx.tap
            .bind(to: onLeftButtonTouched)
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        viewModelOutput
            .eventImageDriver
            .drive(customView.imageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModelOutput
            .eventTitleDriver
            .drive(customView.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModelOutput
            .eventDateDriver
            .drive(customView.dateStackView.label.rx.text)
            .disposed(by: disposeBag)
        
        viewModelOutput
            .eventAddressDriver
            .drive(customView.addressStackView.label.rx.text)
            .disposed(by: disposeBag)
        
        viewModelOutput
            .eventDescriptionDriver
            .drive(customView.descriptionTextLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK:- Overriding
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupMapView()
        setupCheckinButton()
        setupOnCheckinDone()
        setupOnFacebookShare()
    }
}

//MARK: MapView Setup
extension EventDetailViewController: MKMapViewDelegate {
    private func setupMapView() {
        customView.mapView.showsUserLocation = true
        viewModel.coordinateRegion.asObservable()
            .subscribe(onNext: { [weak self] (coordinate) in
                self?.customView.mapView.setRegion(coordinate, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.coordinates.asObservable()
            .map { $0 }
            .flatMap(createAnnotation)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func createAnnotation(_ eventLocation: CLLocationCoordinate2D) -> Observable<Void> {
        Observable.create { [weak self] observable -> Disposable in
            let annotation = MKPointAnnotation()
            annotation.title = "Local do Evento"
            annotation.coordinate = eventLocation
            self?.customView.mapView.addAnnotation(annotation)
            observable.onCompleted()
            return Disposables.create{}
        }
    }
    
    private func setupCheckinButton() {
        viewModel.event.asObservable()
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                self.customView.checkinButtons.configViewComponents(rightButtonTitle: "Check-in - R$ \(event.price ?? 0.0)", view: self.view)
            }).disposed(by: disposeBag)
    }
    
    private func setupOnCheckinDone() {
        viewModel.didCheckinWithSuccess.asObservable()
            .skip(1)
            .filter{$0}
            .flatMap{ _ in self.didPerformCheckinWithSuccess() }
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.didCheckinWithSuccess.asObservable()
            .skip(1)
            .filter{!$0}
            .flatMap{ _ in self.didPerformCheckinWithError() }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func didPerformCheckinWithError() -> Observable<Void> {
        Observable.create { (observable) -> Disposable in
            DispatchQueue.main.async {
                Alert.show(title: "Ops",
                           message: "Não foi possível realizar seu check-in neste evento. Tente novamente mais tarde!",
                           viewController: self)
            }
            observable.onCompleted()
            return Disposables.create {}
        }
    }
    
    private func didPerformCheckinWithSuccess() -> Observable<Void> {
        Observable.create { (observable) -> Disposable in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.35) {
                    self.customView.checkinButtons.configViewComponents(rightButtonTitle: "Você está confirmado!", leftButtonTitle: "Compartilhar", view: self.view)
                    self.view.layoutIfNeeded()
                }
                self.customView.checkinButtons.isActionButtonEnabled.accept(false)
            }
            observable.onCompleted()
            return Disposables.create {}
        }
    }
    
    func setupOnFacebookShare() {
        viewModel.shareContent.asObservable()
        .skip(1)
            .subscribe(onNext: { (shareContent) in
                DispatchQueue.main.async {
                    let shareDialog = ShareDialog(fromViewController: self, content: shareContent ?? ShareLinkContent(), delegate: self)
                    shareDialog.mode = .automatic
                    shareDialog.show()
                }
            }).disposed(by: disposeBag)
    }
}

//MARK: FacebookShare Delegate
extension EventDetailViewController: SharingDelegate {
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        
    }
}
