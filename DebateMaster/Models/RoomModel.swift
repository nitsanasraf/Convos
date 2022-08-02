//
//  RoomModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import Foundation

class RoomModel:Codable {
    let id:UUID
    let name:String
    let colors:[String]
    let category:String
    var availablePositions:[Bool]
}
