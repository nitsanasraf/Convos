//
//  KeyCenter.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 02/07/2022.
//

import UIKit

struct KeyCenter {
    static var appID: String?
    static var appCertificate: String?
    
    static func getKeys(viewController vc: UIViewController, completionHandler: @escaping ()->()) {
        let networkManager = NetworkManger()
        networkManager.fetchData(type: [String:String].self, url: "\(networkManager.agoraURL)/\(Constants.Network.EndPoints.keys)", withEncoding: true) { (statusCode,keys,_) in
            networkManager.handleErrors(statusCode: statusCode, viewController: vc)
            guard let keysDict = keys else { return }
            KeyCenter.appID = keysDict["APP_ID"]
            KeyCenter.appCertificate = keysDict["APP_CERTIFICATE"]
            completionHandler()
        }
    }
}
