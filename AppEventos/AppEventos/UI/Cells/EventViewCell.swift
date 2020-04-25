//
//  EventViewCell.swift
//  EventsApp
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2019 Douglas Immig. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class EventViewCell : UITableViewCell {
    
    // MARK: Private properties
    private var disposeBag = DisposeBag()
    static var reusableIdentifier: String = "eventCell"
    static var nibName: String = "EventViewCell"
    
    @IBOutlet weak var eventImage: UIImageView! {
        didSet {
            eventImage.layer.masksToBounds = true
            eventImage.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var infoView: UIView! {
        didSet {
            infoView.layer.masksToBounds = true
            infoView.layer.cornerRadius = 10
            infoView.layer.borderWidth = 0.3
            infoView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    
    func bind(viewModel: EventCellViewModel) {
        viewModel.titleObservable
            .bind(to: title.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.priceObservable
            .bind(to: price.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.monthObservable
            .bind(to: month.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.dayObservable
            .bind(to: day.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.imageObservable
            .bind(to: eventImage.rx.image)
            .disposed(by: disposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
   
}


