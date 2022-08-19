//
//  Constants.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import UIKit


struct Constants {
    struct Network {
        static let baseHttpURL = "http://localhost:8080/"
        static let baseSocketURL = "ws://localhost:8080/"
        static let schemeName = "debatemaster"
        struct EndPoints {
            static let rooms = "rooms"
            static let socket = "socket"
            static let google = "google"
            static let facebook = "facebook"
            static let users = "users"
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
            static let userUID = "userUID"
            static let userAuthToken = "userAuthToken"
            static let userEmail = "userEmail"

        }
    }
    struct Colors {
        static let primaryGradient: UIColor = UIColor(red: 0.85, green: 0.13, blue: 1.00, alpha: 1.00)
        static let secondaryGradient: UIColor = UIColor(red: 0.59, green: 0.20, blue: 0.93, alpha: 1.00)
        static let primaryText: UIColor = .white
    }
}
