//
//  EventDetailView.swift
//  AppEventos
//
//  Created by Douglas Immig on 25/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import UIKit
import ExpandableLabel
import MapKit

class EventDetailView: UIView {
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "back-button"), for: .normal)
        button.isEnabled = true
        return button
    }()
    
    var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        return label
    }()
    
    var dateStackView: IconLabelStackView = {
        let stackView = IconLabelStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.center
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    var addressStackView: IconLabelStackView = {
        let stackView = IconLabelStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.center
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.text = "Descrição"
        return label
    }()
    
    var descriptionTextLabel: ExpandableLabel = {
        let label = ExpandableLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shouldCollapse = true
        label.setLessLinkWith(lessLink: "Menos", attributes: [.foregroundColor:UIColor.black], position: .left)
        label.collapsedAttributedLink = NSAttributedString(string: "Mais")
        label.textReplacementType = .word
        label.numberOfLines = 5
        label.collapsed = true
        label.font = UIFont(name: "HelveticaNeue-Ligth", size: 14)
        return label
    }()
    
    var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        return map
    }()
    
    var checkinButtons: CheckinButtonsStackView = {
        let stackView = CheckinButtonsStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = 0
        return stackView
    }()
    
    // MARK: Initializers
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: Setup Layout
    func setupView() {
        addSubviews()
        setupConstraints()
        backgroundColor = .white
    }
    
    private func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateStackView)
        contentView.addSubview(addressStackView)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionTextLabel)
        contentView.addSubview(mapView)
        addSubview(checkinButtons)
    }
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupContentViewConstraints()
        setupBackButtonConstraints()
        setupImageViewConstraints()
        setupTitleLabelConstraints()
        setupDateStackViewConstraints()
        setupAddressStackViewConstraints()
        setupDescriptionTitleLabel()
        setupDescriptionTextLabel()
        setupMapViewConstraints()
    }
    
    private func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: checkinButtons.topAnchor),
        ])
    }
    
    private func setupContentViewConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setupImageViewConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func setupBackButtonConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 32),
            backButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            backButton.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupDateStackViewConstraints() {
        NSLayoutConstraint.activate([
            dateStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            dateStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            dateStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupAddressStackViewConstraints() {
        NSLayoutConstraint.activate([
            addressStackView.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: 16),
            addressStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            addressStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupDescriptionTitleLabel() {
        NSLayoutConstraint.activate([
            descriptionTitleLabel.topAnchor.constraint(equalTo: addressStackView.bottomAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            descriptionTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupDescriptionTextLabel() {
        NSLayoutConstraint.activate([
            descriptionTextLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            descriptionTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupMapViewConstraints() {
        NSLayoutConstraint.activate([
            mapView.heightAnchor.constraint(equalToConstant: 300),
            mapView.topAnchor.constraint(equalTo: descriptionTextLabel.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
