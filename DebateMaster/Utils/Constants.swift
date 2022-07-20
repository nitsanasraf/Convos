//
//  Constants.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/07/2022.
//

import Foundation


struct Constants {
    struct Network {
        static let baseHttpURL = "http://127.0.0.1:8080/"
        static let baseSocketURL = "ws://127.0.0.1:8080/"
        struct EndPoints {
            static let rooms = "rooms"
            static let socket = "socket"
        }
    }
}
