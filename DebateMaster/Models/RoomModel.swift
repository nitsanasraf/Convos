//
//  RoomModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import UIKit
import AgoraRtcKit

class RoomModel:Codable {
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
    
    static func findEmptyRoom(fromRoom existingRoom: RoomModel?, networkManager: NetworkManger, category: String?, viewController vc: UIViewController, agoraKit:AgoraRtcEngineKit?) {
        guard let urlCategory = category?.makeURLSafe(),
              let strUID = UserModel.shared.uid,
              let userUID = UInt(strUID),
              let userID = UserModel.shared.id else {return}
        
        var roomURL = "\(networkManager.roomsURL)/\(Constants.Network.EndPoints.find)/\(urlCategory)/\(userID)"
        
        if let existingRoom = existingRoom {
            roomURL = "\(networkManager.roomsURL)/\(Constants.Network.EndPoints.next)/\(existingRoom.category)/\(existingRoom.id)"
        }
        
        networkManager.fetchData(type: RoomModel.self, url: roomURL) { [weak vc] room in
            guard let vc = vc else {return}
            
            let url = "\(networkManager.rtcURL)/\(KeyCenter.appID)/\(KeyCenter.appCertificate)/\(room.name)/\(userUID)"
            guard let url = URL(string: url) else {return}
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error fetching: \(error)")
                } else {
                    guard let data = data else {return}
                    guard let token = String(data: data, encoding: .utf8) else {return}
                    UserModel.shared.agoraToken = token
                    DispatchQueue.main.async {
                        agoraKit?.leaveChannel()
                        agoraKit?.joinChannel(byToken: UserModel.shared.agoraToken, channelId: room.name, info: nil, uid: userUID, joinSuccess: { (channel, uid, elapsed) in
                            print("User has successfully joined the channel: \(channel)")
                            RoomModel.moveToRoom(room: room, fromViewController: vc, withTitle: category)
                        })
                    }
                }
            }
            task.resume()
            
        }
    }
    
    static func getEmojiName(categoryName: String) -> String{
        switch categoryName {
        case "History": return "History 📖"
        case "Politics": return "Politics 📋"
        case "Economics": return "Economics 📉"
        case "Law": return "Law 📜"
        case "Technology": return "Technology 🤖"
        case "Science": return "Science 🪐"
        default: return ""
        }
    }
}
