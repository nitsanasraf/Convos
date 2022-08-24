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
    let usersURL = Constants.Network.baseHttpURL + Constants.Network.EndPoints.users
    let rtcURL = Constants.Network.baseHttpURL + Constants.Network.EndPoints.rtc
    let schemeName = Constants.Network.schemeName
    
    var webSocketTask:URLSessionWebSocketTask?
    
    mutating func configureWebSocketTask(userID:String, roomID:String) {
        guard let url = URL(string:"\(socketURL)/\(userID)/\(roomID)") else {return}
        guard let token = UserModel.shared.authToken else {return}

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        self.webSocketTask = URLSession(configuration: .default).webSocketTask(with: request)
    }
    
    func fetchData<T:Decodable>(type:T.Type, url:String, withEncoding:Bool, completionHandler: @escaping (Int,T?,Data?)->()) {
        guard let url = URL(string: url) else {return}
        guard let token = UserModel.shared.authToken else {return}
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching: \(error)")
            } else {
                guard let data = data else {return}
                guard let statusCode = response?.getStatusCode() else {return}
                if withEncoding {
                    let decodedData = try? JSONDecoder().decode(type, from: data)
                    completionHandler(statusCode,decodedData, nil)
                }
                else {
                    completionHandler(statusCode, nil, data)
                }
            }
        }
        task.resume()
    }
    
    
    func sendData<T:Encodable>(object:T, url:String, httpMethod:String, completionHandler: @escaping (Data, Int)->()) {
        guard let url = URL(string: url) else {return}
        guard let token = UserModel.shared.authToken else {return}
        
        var request = URLRequest(url: url)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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
                guard let statusCode = response?.getStatusCode() else {return}

                completionHandler(data,statusCode)
            }
        }
        task.resume()
    }
        
    func delete(url: String, completionHandler: @escaping (Int)->()) {
        guard let url = URL(string:url) else {return}
        guard let token = UserModel.shared.authToken else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = Constants.HttpMethods.DELETE.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (_,response,error) in
            if let error = error {
                print("Error deleting object from server: \(error)")
            } else {
                guard let statusCode = response?.getStatusCode() else {return}
                completionHandler(statusCode)
            }
        }
        task.resume()
    }
    
    func handleClientErrors(code: Int, error: ()->() ) {
        switch code {
        case 100...199: print("Information")
        case 200...299: print("Success")
        case 300...399: print("Redirect")
        case 401:
            error()
        case 400...499: print("Client error")
        case 500...599: print("Server error")
        default: break
        }
    }
}

