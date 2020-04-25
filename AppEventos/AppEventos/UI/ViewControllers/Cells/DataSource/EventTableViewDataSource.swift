//
//  EventTableViewDataSource.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources

protocol EventCellProtocol {
    associatedtype ViewModel
    
    static var reusableIdentifier: String { get }
    static var nibName: String { get }
    var viewModel: ViewModel? { get }
    func bind(viewModel: ViewModel)
}

enum EventCells {
    case EventCell(viewModel: EventCellViewModel)
    
    func height() -> CGFloat {
        switch self {
        case .EventCell(_):
            return 70.0
        }
    }
    
    func cellIn(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .EventCell(let viewModel):
            let cell: EventViewCell =
                tableView.dequeueReusableCell(withIdentifier: EventViewCell.reusableIdentifier ) as! EventViewCell
            cell.bind(viewModel: viewModel)
            return cell
        }
    }
}

enum EventSectionModel {
    case Event(title: String, items: [EventCells])
}

extension EventSectionModel: SectionModelType {
    typealias Item = EventCells

    init(original: EventSectionModel, items: [EventCells]) {
        switch original {
        case let .Event(title: title, items: _):
            self = .Event(title: title, items: items)
        }
    }
    
    var items: [EventCells] {
        switch  self {
        case .Event(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    var title: String {
        switch self {
        case .Event(title: let title, items: _):
            return title
        }
    }
}
