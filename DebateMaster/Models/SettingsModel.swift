//
//  SettingsModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 16/08/2022.
//

import Foundation


struct SettingsModel {
    
    static let shared = SettingsModel()
    
    private init() {}
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    struct Item {
        let title: String
        let icon: String
        let function: () -> ()
    }
    
    let sections = [
        Section(title: "Privacy" ,items: [
            Item(title: "Notifications", icon: "bell.fill") {
                print("Notifications")
            },
            Item(title: "Data collection", icon: "antenna.radiowaves.left.and.right") {
                print("Data collection")
            },
            Item(title: "Networking", icon: "network") {
                print("Networking")
            },
        ]),
        Section(title: "Account" ,items: [
            Item(title: "Logout", icon: "arrow.uturn.left") {
                print("Logout")
            },
            Item(title: "Delete account", icon: "trash.fill") {
                print("Delete account")
            },
        ]),
        Section(title: "Policies" ,items: [
            Item(title: "Privacy policy", icon: "checkerboard.shield") {
                print("Privacy policy")
            },
            Item(title: "Terms and conditions", icon: "newspaper") {
                print("Terms and conditions")
            },
        ]),
    ]
    
    //    private func logout() {
    //        guard let url = URL(string: "\(networkManager.usersURL)/\(Constants.Network.EndPoints.logout)") else {return}
    //        let task = URLSession.shared.dataTask(with: url) { (_, response, error) in
    //            if let error = error {
    //                print("Error fetching: \(error)")
    //            } else {
    //                KeyChain.shared.deleteAll()
    //                UserModel.shared.resetUser()
    //                DispatchQueue.main.async {
    //                    self.navigationController?.popToRootViewController(animated: true)
    //                }
    //            }
    //        }
    //        task.resume()
    //    }
    
}
