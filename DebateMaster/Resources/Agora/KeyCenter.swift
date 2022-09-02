//
//  KeyCenter.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 02/07/2022.
//

import UIKit

struct KeyCenter {
    static var appID: String?
    
    static func getAppID(viewController vc: UIViewController, completionHandler: @escaping ()->()) {
        let networkManager = NetworkManger()
        networkManager.fetchData(type: String.self, url: "\(networkManager.agoraURL)/\(Constants.Network.EndPoints.keys)", withEncoding: false) { (statusCode,_,data) in
            networkManager.handleErrors(statusCode: statusCode, viewController: vc)
            guard let data = data else {return}
            let decodedKey = String(data: data, encoding: .utf8)
            KeyCenter.appID = decodedKey
            completionHandler()
        }
    }
}
