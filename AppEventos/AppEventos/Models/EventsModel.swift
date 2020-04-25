//
//  EventsModel.swift
//  AppEventos
//
//  Created by Douglas Immig on 24/04/20.
//  Copyright © 2020 Douglas de Carli Immig. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Event: Codable {
    let people: [People]
    let date: Double
    let description: String
    let image: String
    let longitude: Double
    let latitude: Double
    let price: Double
    let title: String
    let id: String
    let cupons: [Cupom]
}

struct People: Codable {
    let id: String
    let eventId: String
    let name: String
    let picture: String
}

struct Cupom: Codable {
    let id: String
    let eventId: String
    let discount: Double
}
