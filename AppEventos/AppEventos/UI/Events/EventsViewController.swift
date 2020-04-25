//
//  EventsViewController.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class EventsViewController: UIViewController {
    
    typealias CustomView = EventsView
    typealias ViewModel = EventsViewModel
    typealias DataSource = RxTableViewSectionedReloadDataSource<EventSectionModel>
    
    // Declare your IBOutletHere
    let customView = CustomView()
    
    // MARK:- Private Variables
    private let disposeBag = DisposeBag()
    
    // MARK: - ViewModel
    var viewModel: ViewModel!
    
    // MARK:- Init
    init(viewModel: ViewModel){
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dataSource = DataSource(configureCell: { (dataSource, table, indexPath, item) in
        let item = dataSource[indexPath]
        return item.cellIn(tableView: table, at: indexPath)
    }, canEditRowAtIndexPath: { dataSource, indexPath in
        return true
    })
    
    private func setupTableView() {
        customView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        customView.tableView.separatorStyle = .none
        customView.tableView.backgroundColor = .clear
        registerCells()
        customView.tableView.rx.modelSelected(EventCells.self).subscribe(onNext: { (cell) in
            switch cell {
            case .EventCell(let viewModel):
                viewModel.didPressed.on(.next(()))
            }
        }).disposed(by: disposeBag)
    }
    
    private func populateTableView() {
        viewModel.data
            .bind(to: customView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK:- Overriding
    override func loadView() {
        view = customView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        populateTableView()
    }
}

// MARK: - Register Cells
extension EventsViewController {
    private func registerCells() {
        customView.tableView.register(UINib(nibName: EventViewCell.nibName,
                                 bundle: .main),
                           forCellReuseIdentifier: EventViewCell.reusableIdentifier)
        
        customView.tableView.register(UINib(nibName: EventSectionHeader.nibName,
                                 bundle: .main),
                           forHeaderFooterViewReuseIdentifier: EventSectionHeader.reusableIdentifier)
    }
}

// MARK: - Table View Delegate
extension EventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = dataSource[indexPath]
        return item.height()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: EventSectionHeader.reusableIdentifier)
            as! EventSectionHeader
        
        sectionHeader.bind(title: dataSource[section].title)
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch dataSource[section] {
        case .Event(title: _, items: _):
            return 56
        }
    }
}
