//
//  Alert.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import UIKit

class Alert {
    
    static func show(title: String, message: String, viewController: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.red
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (alertAction) -> Void in
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
