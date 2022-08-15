//
//  UserModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 29/07/2022.
//

import Foundation


struct UserModel:Codable {
    
    static var shared = UserModel()
    
    var email: String?
    var id: String?
    var uid: String?
    var authToken: String?
    var agoraToken: String?
    
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
    
    func resetUser() {
        UserModel.shared.email = nil
        UserModel.shared.id = nil
        UserModel.shared.uid = nil
        UserModel.shared.authToken = nil
        UserModel.shared.agoraToken = nil
    }
    
    
    func printDetails() -> Void {
        print("ID: \(self.id ?? "")\nUID:\(self.uid ?? "")\nEmail: \(self.email ?? "")\nToken: \(self.authToken ?? "")")
    }
    
}
