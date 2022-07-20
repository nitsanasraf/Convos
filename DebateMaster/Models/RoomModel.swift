//
//  RoomModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import Foundation

class RoomModel:Codable {
    let id:UUID?
    let name:String
    let colors:[String]
    let category:String
    var availablePositions:[Bool]
    
    init(id:UUID? = nil,
         name:String = "Example",
         colors:[String] = ["white","purple","vibrant yellow","green","orange","cyan blue"].shuffled(),
         category:String,
         availablePositions:[Bool] = [false,false,false,false,false,false]) {
        self.id = id
        self.name = name
        self.colors = colors
        self.category = category
        self.availablePositions = availablePositions
    }
}
