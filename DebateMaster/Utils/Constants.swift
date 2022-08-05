//
//  Constants.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import UIKit


struct Constants {
    struct Network {
        static let baseHttpURL = "http://127.0.0.1:8080/"
        static let baseSocketURL = "ws://127.0.0.1:8080/"
        static let schemeName = "debatemaster"
        struct EndPoints {
            static let rooms = "rooms"
            static let socket = "socket"
            static let google = "google"
            static let facebook = "facebook"
        }
    }
    enum HttpMethods:String {
        case POST
        case PUT
        case DELETE
    }
    struct KeyChain {
        struct Keys {
            static let userID = "userID"
            static let userAuthToken = "userAuthToken"
            static let userEmail = "userEmail"
            static let userAgoraToken = "userAgoraToken"
        }
    }
    struct Colors {
        static let primary: UIColor = .systemPink
    }
}
