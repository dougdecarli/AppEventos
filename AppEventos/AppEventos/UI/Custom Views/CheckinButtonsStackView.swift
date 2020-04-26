//
//  CheckinButtonsStackView.swift
//  AppEventos
//
//  Created by Douglas Immig on 25/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CheckinButtonsStackView: UIStackView {
    
    var rigthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        return button
    }()
    
    var leftButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    var isActionButtonEnabled = BehaviorRelay<Bool>(value: true)
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        setupRightButtonInteraction()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configViewComponents(rightButtonTitle: String, leftButtonTitle: String? = nil, view: UIView){
        if leftButtonTitle != nil{
            self.addArrangedSubview(leftButton)
            leftButton.setTitle(leftButtonTitle, for: .normal)
        }
        
        self.addArrangedSubview(rigthButton)
        rigthButton.setTitle(rightButtonTitle, for: .normal)
        rigthButton.titleLabel?.numberOfLines = 0
        rigthButton.titleLabel?.textAlignment = .center
        leftButton.titleLabel?.numberOfLines = 0
        leftButton.titleLabel?.textAlignment = .center
        
        setupConstraints(view: view)
    }
    
    private func setupConstraints(view: UIView){
        NSLayoutConstraint.activate([
            rigthButton.heightAnchor.constraint(equalToConstant: 56),
            leftButton.heightAnchor.constraint(equalToConstant: 56),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupRightButtonInteraction() {
        isActionButtonEnabled.asObservable()
            .bind(to: rigthButton.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
    }
}
