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
//    let url = "wss://108f-2a00-a040-199-6406-e5c8-f283-1ba5-73ac.eu.ngrok.io/socket"

    let urlSession = URLSession(configuration: .default)
    lazy var webSocketTask = urlSession.webSocketTask(with: URL(string:url)!)
}
