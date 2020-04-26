//
//  TryAgainView.swift
//  AppEventos
//
//  Created by Douglas Immig on 25/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TryAgainView: UIView {
    
    var iconError: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(named: "warning")
        return icon
    }()
    
    var messageDescriptionError: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        return label
    }()
    
    var tryAgainButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 16)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViewComponents(errorMessage: String, buttonTitle: String, view: UIView) {
        messageDescriptionError.text = errorMessage
        tryAgainButton.setTitle(buttonTitle, for: .normal)
        addSubviews()
        setupConstraints(view)
    }
    
    private func addSubviews() {
        self.addSubview(iconError)
        self.addSubview(messageDescriptionError)
        self.addSubview(tryAgainButton)
    }
    
    private func setupConstraints(_ view: UIView) {
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 320),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            iconError.topAnchor.constraint(equalTo: self.topAnchor),
            iconError.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconError.heightAnchor.constraint(equalToConstant: 40),
            iconError.widthAnchor.constraint(equalToConstant: 40),
            
            messageDescriptionError.topAnchor.constraint(equalTo: iconError.bottomAnchor, constant: 20),
            messageDescriptionError.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            messageDescriptionError.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            tryAgainButton.topAnchor.constraint(equalTo: messageDescriptionError.bottomAnchor, constant: 32),
            tryAgainButton.widthAnchor.constraint(equalToConstant: 180),
            tryAgainButton.heightAnchor.constraint(equalToConstant: 42),
            tryAgainButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tryAgainButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
