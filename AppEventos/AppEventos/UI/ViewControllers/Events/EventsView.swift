//
//  EventsView.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit

class EventsView: UIView {
    
    let tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsMultipleSelection = false
        $0.separatorStyle = .none
        return $0
    }(UITableView())
    
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
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        setupTableViewConstraints()
    }
    
    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
}
