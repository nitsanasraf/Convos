//
//  Constants.swift
//  Convos
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import UIKit


struct Constants {
    struct Network {
        static let baseHttpURL = "http://127.0.0.1:8080/"
        static let baseSocketURL = "ws://127.0.0.1:8080/"
        static let schemeName = "convos"
        struct EndPoints {
            static let rooms = "rooms"
            static let find = "find"
            static let next = "next"
            static let socket = "socket"
            static let google = "google"
            static let facebook = "facebook"
            static let users = "users"
            static let logout = "logout"
            static let agora = "agora"
            static let keys = "keys"
            static let categories = "categories"
            static let deleted = "deleted"
        }
    }
    enum HttpMethods: String {
        case POST
        case PUT
        case DELETE
    }
    struct KeyChain {
        struct Keys {
            static let userID = "userID"
            static let userUID = "userUID"
            static let userAuthToken = "userAuthToken"
            static let userEmail = "userEmail"
            static let userSeconds = "userSeconds"
        }
    }
    struct Colors {
        static let primaryGradient = UIColor(red: 0.63, green: 0.27, blue: 1.00, alpha: 1.00)
        static let secondaryGradient = UIColor(red: 0.42, green: 0.19, blue: 0.58, alpha: 1.00)
        static let tertiaryGradient = UIColor(red: 1.00, green: 0.83, blue: 0.19, alpha: 1.00)
        static let quaternaryGradient = UIColor(red: 0.98, green: 0.81, blue: 0.18, alpha: 1.00)
        static let primaryText: UIColor = .white
        static let secondaryText = UIColor(red: 0.20, green: 0.12, blue: 0.59, alpha: 1.00)
    }
}
