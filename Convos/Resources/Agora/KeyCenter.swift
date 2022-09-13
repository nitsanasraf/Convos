//
//  KeyCenter.swift
//  Convos
//
//  Created by Nitsan Asraf on 02/07/2022.
//

import UIKit


struct KeyCenter {
    static var appID: String?
    
    struct KeysHandler:Codable {
        let key: String
        let app: Data
    }
    
    static func getKeys(viewController vc: UIViewController, completionHandler: @escaping ()->()) {
        let networkManager = NetworkManger()
        networkManager.fetchData(type: KeysHandler.self, url: "\(networkManager.agoraURL)/\(Constants.Network.EndPoints.keys)", withEncoding: true) { (statusCode,keysHandler,_) in
            networkManager.handleErrors(statusCode: statusCode, viewController: vc)
            guard let keysHandler = keysHandler else {return}
            let aes = try? AESModel(keyString: keysHandler.key)
            let appID = try? aes?.decrypt(keysHandler.app)
            KeyCenter.appID = appID
            completionHandler()
        }
    }
}
