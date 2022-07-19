//
//  WebSocketModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 07/07/2022.
//

import Foundation

struct NetworkManger {
    
    let getColorsURL = "http://127.0.0.1:8080/colors"
    let getPostPositionURL = "http://127.0.0.1:8080/positions"
    
    let socketURL = "ws://127.0.0.1:8080/socket"

    let urlSession = URLSession(configuration: .default)
    lazy var webSocketTask = urlSession.webSocketTask(with: URL(string:socketURL)!)
    
}
