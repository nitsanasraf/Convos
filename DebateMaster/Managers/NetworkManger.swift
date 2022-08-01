//
//  WebSocketModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 07/07/2022.
//

import Foundation

struct NetworkManger {
    
    let roomsURL = Constants.Network.baseHttpURL + Constants.Network.EndPoints.rooms
    let socketURL = Constants.Network.baseSocketURL + Constants.Network.EndPoints.socket
    let authGoogleURL = Constants.Network.baseHttpURL + Constants.Network.EndPoints.google
    let authFacebookURL = Constants.Network.baseHttpURL + Constants.Network.EndPoints.facebook
    let schemeName = Constants.Network.schemeName
    
    var webSocketTask:URLSessionWebSocketTask?
    
    mutating func configureWebSocketTask(userID:String, roomID:String) {
        guard let url = URL(string:"\(socketURL)/\(userID)/\(roomID)") else {return}
        self.webSocketTask = URLSession(configuration: .default).webSocketTask(with: url)
    }
    
    func fetchData<T:Decodable>(type:T.Type, url:String, completionHandler: @escaping (T)->()) {
        guard let url = URL(string: url) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching: \(error)")
            } else {
                guard let data = data else {return}
                do {
                    let decodedData = try JSONDecoder().decode(type, from: data)
                    completionHandler(decodedData)
                } catch {
                    print("Error decoding fetched data: \(error)")
                }
            }
        }
        task.resume()
    }
    
    
    func sendData<T:Encodable>(object:T, url:String, httpMethod:String, completionHandler: @escaping (Data,URLResponse)->()) {
        guard let url = URL(string: url) else {return}
        var request = URLRequest(url: url)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        do {
            request.httpBody = try JSONEncoder().encode(object)
        } catch {
            print("Error encoding the request body : \(error)")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error posting to server: \(error)")
            } else {
                guard let data = data else {return}
                guard let response = response else {return}
                
                completionHandler(data,response)
            }
        }
        task.resume()
    }
        
    func delete(url: String, completionHandler: @escaping (URLResponse)->()) {
        guard let url = URL(string:url) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = Constants.HttpMethods.DELETE.rawValue
        let task = URLSession.shared.dataTask(with: request) { (_,response,error) in
            if let error = error {
                print("Error deleting object from server: \(error)")
            } else {
                guard let response = response else {return}
                completionHandler(response)
            }
        }
        task.resume()
    }
    
}
