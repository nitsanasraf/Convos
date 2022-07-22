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
    
    init(id: UUID, category: String) {
        self.id = id
        self.name = category + id.uuidString
        self.colors = ["white","purple","vibrant yellow","green","orange","cyan blue"].shuffled()
        self.category = category
        self.availablePositions = [false,false,false,false,false,false]
    }
}
