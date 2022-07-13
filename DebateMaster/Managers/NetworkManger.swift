//
//  WebSocketModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 07/07/2022.
//

import Foundation

struct NetworkManger {
    static var shared = NetworkManger()
    
    let socketURL = "ws://127.0.0.1:8080/socket"
    let getColorsURL = "http://127.0.0.1:8080/color"
    
    let urlSession = URLSession(configuration: .default)
    lazy var webSocketTask = urlSession.webSocketTask(with: URL(string:socketURL)!)
}
