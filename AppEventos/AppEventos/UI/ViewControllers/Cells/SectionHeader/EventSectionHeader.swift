//
//  EventSectionHeader.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit
import RxSwift

class EventSectionHeader: UITableViewHeaderFooterView {
    static var nibName: String = "EventSectionHeader"
    static var reusableIdentifier: String = "eventSectionHeader"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    let disposeBag = DisposeBag()
    func bind(title: String?) {
        backgroundColor = .white
        Observable.just(title)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
