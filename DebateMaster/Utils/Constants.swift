//
//  Constants.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import UIKit


struct Constants {
    struct Network {
        static let baseHttpURL = "https://76bc-157-25-124-212.eu.ngrok.io/"
        static let baseSocketURL = "wss://76bc-157-25-124-212.eu.ngrok.io/"
        static let schemeName = "debatemaster"
        struct EndPoints {
            static let rooms = "rooms"
            static let socket = "socket"
            static let google = "google"
            static let facebook = "facebook"
            static let users = "users"
            static let topics = "topics"
            static let logout = "logout"
            static let rtc = "rtc"
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
        }
    }
    struct Colors {
        static let primary: UIColor = .systemPink
    }
}
