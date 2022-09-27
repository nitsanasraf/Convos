//
//  RoomModel.swift
//  Convos
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import UIKit
import AgoraRtcKit

class RoomModel: Codable {
    let id: UUID
    let name: String
    let colors: [String]
    let category: String
    var positions: [String]
    let currentTopic: String
    var currentVotes: [[String:String]]
    
    static func moveToRoom(room:RoomModel, fromViewController vc: UIViewController, withTitle title :String?) {
        let roomVC = RoomViewController()
        roomVC.title = title
        roomVC.room = room
        vc.navigationController?.pushViewController(roomVC, animated: true)
    }
    
    static func findEmptyRoom(fromRoom existingRoom: RoomModel?, networkManager: NetworkManger, category: String?, viewController vc: UIViewController, completionHandler: @escaping (RoomModel,UInt)->()) {
        guard let urlCategory = category?.trimmingCharacters(in: .whitespacesAndNewlines),
              let strUID = UserModel.shared.uid,
              let userUID = UInt(strUID),
              let userID = UserModel.shared.id else {return}
        
        var roomURL = "\(networkManager.roomsURL)/\(Constants.Network.EndPoints.find)/\(urlCategory)/\(userID)"
        if let existingRoom = existingRoom {
            roomURL = "\(networkManager.roomsURL)/\(Constants.Network.EndPoints.next)/\(existingRoom.category)/\(existingRoom.id)/\(userID)"
        }
        //Fetch room
        networkManager.fetchData(type: RoomModel.self, url: roomURL) { [weak vc] (statusCode, room,_) in
            guard let vc = vc else {return}
            networkManager.handleErrors(statusCode: statusCode, viewController: vc)
            if statusCode >= 200 && statusCode <= 299 {
                guard let room = room else { return }
                guard let appID = KeyCenter.appID else {return}
                let url = "\(networkManager.agoraURL)/\(appID)/\(room.name)/\(userUID)"
                //Fetch token
                networkManager.fetchData(type: String.self, url: url) { (statusCode,_,data) in
                    networkManager.handleErrors(statusCode: statusCode, viewController: vc)
                    if statusCode >= 200 && statusCode <= 299 {
                        guard let data = data else { return }
                        guard let token = String(data: data, encoding: .utf8) else {return}
                        UserModel.shared.agoraToken = token
                        completionHandler(room,userUID)
                    }
                }
            }
        }
    }
}
