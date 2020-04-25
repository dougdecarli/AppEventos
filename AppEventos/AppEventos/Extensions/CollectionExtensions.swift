//
//  CollectionExtensions.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return safeGet(atIndex: index)
    }
    
    func safeGet(atIndex index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
