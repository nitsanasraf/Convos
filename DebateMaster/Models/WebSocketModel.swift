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
//    let url = "wss://6286-2a00-a040-199-6406-38a5-9800-a0c6-3211.eu.ngrok.io/socket"

    let urlSession = URLSession(configuration: .default)
    lazy var webSocketTask = urlSession.webSocketTask(with: URL(string:url)!)
}
