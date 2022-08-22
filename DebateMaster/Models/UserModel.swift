//
//  UserModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 29/07/2022.
//

import UIKit


struct UserModel:Codable {
    
    static var shared = UserModel()
    
    var id: String?
    var uid: String?
    var createdAt: String?
    var email: String?
    var authToken: String?
    var agoraToken: String?
    var categoriesCount: [[String:String]]?
    
    private init() {}
    
    func populateUser(token: String?, email: String?, id: String?, uid: String?) {
        UserModel.shared.authToken = token
        UserModel.shared.email = email
        UserModel.shared.id = id
        UserModel.shared.uid = uid
    }
    
    func isUserLoggedIn() -> Bool {
        if let authToken = KeyChain.shared[Constants.KeyChain.Keys.userAuthToken],
           let email = KeyChain.shared[Constants.KeyChain.Keys.userEmail],
           let id = KeyChain.shared[Constants.KeyChain.Keys.userID],
           let uid = KeyChain.shared[Constants.KeyChain.Keys.userUID] {
            populateUser(token: authToken, email: email, id: id, uid: uid)
            return true
        }
        return false
    }
    
    private func resetUser() {
        UserModel.shared.email = nil
        UserModel.shared.id = nil
        UserModel.shared.uid = nil
        UserModel.shared.authToken = nil
        UserModel.shared.agoraToken = nil
        UserModel.shared.createdAt = nil
        UserModel.shared.categoriesCount = nil
    }

    func logout(viewController vc:UIViewController, networkManager: NetworkManger) {
        guard let url = URL(string: "\(networkManager.usersURL)/\(Constants.Network.EndPoints.logout)") else {return}
        let task = URLSession.shared.dataTask(with: url) { (_, response, error) in
            if let error = error {
                print("Error fetching: \(error)")
            } else {
                KeyChain.shared.deleteAll()
                self.resetUser()
                DispatchQueue.main.async {
                    vc.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        task.resume()
    }
    
    func getFavouriteCategory() -> String? {
        guard let categoriesCount = self.categoriesCount else {return nil}
        
        if let category = categoriesCount.max(by: { Int($0["count"]!)! < Int($1["count"]!)! }) {
            if Int(category["count"]!) == 0 {
                return nil
            }
            return category["category"]
        }
        return nil
    }
    
    
    
    func printDetails() -> Void {
        print("ID: \(self.id ?? "")\nUID:\(self.uid ?? "")\nEmail: \(self.email ?? "")\nToken: \(self.authToken ?? "")")
    }
    
}
