//
//  IconLabelStackView.swift
//  AppEventos
//
//  Created by Douglas Immig on 25/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit

class IconLabelStackView: UIStackView {
    
    var icon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "calendar")
        return image
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0 
        label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addArrangedSubview(icon)
        addArrangedSubview(label)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 24),
            icon.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}
