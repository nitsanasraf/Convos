//
//  RoomModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import UIKit

class RoomModel:Codable {
    let id: UUID
    let name: String
    let colors: [String]
    let category: String
    var availablePositions: [Bool]
 
    
    static func moveToRoom(room:RoomModel, topics: [TopicModel], fromViewController vc: UIViewController, withTitle title :String?) {
        let roomVC = RoomViewController()
        roomVC.title = title
        roomVC.room = room
        roomVC.topics = topics
        vc.navigationController?.pushViewController(roomVC, animated: true)
    }
    
    
}
