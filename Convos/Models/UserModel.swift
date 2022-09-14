//
//  UserModel.swift
//  Convos
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
    var secondsSpent: Int?
    
    var freeTierLimit: Float? = 35.0
  
    var minutesSpent: Float? {
        guard let secondsSpent = secondsSpent else {return nil}
        return Float(secondsSpent)/60
    }
    
    var didExceedFreeTierLimit: Bool? {
        guard let minutesSpent = minutesSpent else {return nil}
        guard let freeTierLimit = freeTierLimit else {return nil}
        return minutesSpent >= freeTierLimit
    }
    
    private init() {}
    
    func populateUser(token: String?, email: String?, id: String?, uid: String?, secondsSpent: Int?) {
        UserModel.shared.authToken = token
        UserModel.shared.email = email
        UserModel.shared.id = id
        UserModel.shared.uid = uid
        UserModel.shared.secondsSpent = secondsSpent
    }
    
    func isUserLoggedIn() -> Bool {
        guard let authToken = KeyChain.shared[Constants.KeyChain.Keys.userAuthToken],
              let email = KeyChain.shared[Constants.KeyChain.Keys.userEmail],
              let id = KeyChain.shared[Constants.KeyChain.Keys.userID],
              let uid = KeyChain.shared[Constants.KeyChain.Keys.userUID],
              let secondsSpent = KeyChain.shared[Constants.KeyChain.Keys.userSeconds],
              let seconds = Int(secondsSpent) else {return false}
        
        populateUser(token: authToken, email: email, id: id, uid: uid, secondsSpent: seconds)
        return true
    }
    
    private func resetUser() {
        UserModel.shared.email = nil
        UserModel.shared.id = nil
        UserModel.shared.uid = nil
        UserModel.shared.authToken = nil
        UserModel.shared.agoraToken = nil
        UserModel.shared.createdAt = nil
        UserModel.shared.categoriesCount = nil
        UserModel.shared.secondsSpent = nil
    }
    
    func handleUnauthorised(viewController vc: UIViewController) {
        logout(viewController: vc)
        DispatchQueue.main.async { [weak vc] in
            guard let vc = vc else {return}
            let alert = UIAlertController(title: "There was an issue with your current session. Please log in again.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            let rootVC = vc.navigationController?.viewControllers.filter { $0 is LoginViewController }.first
            vc.navigationController?.popToRootViewController(animated: true)
            guard let rootVC = rootVC else {return}
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
    
    func logout(viewController vc: UIViewController) {
        guard let url = URL(string: "\(NetworkManger().usersURL)/\(Constants.Network.EndPoints.logout)") else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (_, response, error) in
            if let error = error {
                print("Error fetching: \(error)")
            } else {
                KeyChain.shared.deleteAll()
                self.resetUser()
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
    
    func getTotalRoomsCount() -> Int {
        guard let categoriesCount = self.categoriesCount else {return 0}
        
        let values = categoriesCount.compactMap {Int($0["count"]!)}
        let totalRooms = values.reduce(0) {
            $0 + $1
        }
        return totalRooms
    }
    
    
    func printDetails() -> Void {
        print("ID: \(self.id ?? "")\nUID:\(self.uid ?? "")\nEmail: \(self.email ?? "")\nToken: \(self.authToken ?? "")\nSeconds spent: \(self.secondsSpent ?? -1 )\nMinutes spent: \(self.minutesSpent ?? -1)")
    }
    
}
