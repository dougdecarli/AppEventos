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
    let date: Double?
    let description: String?
    let image: String?
    let longitude: Double?
    let latitude: Double?
    let price: Double?
    let title: String?
    let id: String?
    let cupons: [Cupom]
}

// MARK: - Event MOCK
extension Event {
    static func eventMock() -> Self {
        .init(people: [.peopleMock()], date: 1534784400000, description: "description", image: "image", longitude: 212121, latitude: -21212121, price: 20.33, title: "title", id: "1", cupons: [.cupomMock()])
    }
}

struct People: Codable {
    let id: String?
    let eventId: String?
    let name: String?
    let picture: String?
}

// MARK: - People MOCK
extension People {
    static func peopleMock() -> Self {
        .init(id: "1", eventId: "1", name: "name", picture: "picture.example.com")
    }
}

struct Cupom: Codable {
    let id: String?
    let eventId: String?
    let discount: Double?
}

// MARK: - Cupom MOCK
extension Cupom {
    static func cupomMock() -> Self {
        .init(id: "1", eventId: "1", discount: 20)
    }
}

