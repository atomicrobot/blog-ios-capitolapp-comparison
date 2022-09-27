//
//  StateModel.swift
//  CapitolApp
//
//  Created by Bret Leupen on 9/23/22.
//

import Foundation

struct StateModel: Codable {
    let data : [State]
}

struct State: Codable {
    let abbreviation: String
    let name: String
    let capital: String
    let lat: String
    let long: String
}
