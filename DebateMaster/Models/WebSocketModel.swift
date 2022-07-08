//
//  WebSocketModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 07/07/2022.
//

import Foundation

struct WebSocketModel {
    static var shared = WebSocketModel()
    
    let url = "ws://127.0.0.1:8080/socket"
    let urlSession = URLSession(configuration: .default)
    lazy var webSocketTask = urlSession.webSocketTask(with: URL(string:url)!)
}
