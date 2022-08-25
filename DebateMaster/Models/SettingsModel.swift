//
//  SettingsModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 16/08/2022.
//

import UIKit

struct SettingsModel {
    
    static let shared = SettingsModel()
    
    private init() {}
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    struct Item {
        let title: String
        let color: UIColor
        let icon: String
        let function: (_ vc:UIViewController) -> ()
    }
    
    let sections = [
        Section(title: "Privacy" ,items: [
            Item(title: "Notifications", color: Constants.Colors.primaryText, icon: "bell.fill") { vc in
                print("Notifications")
            },
            Item(title: "Data collection", color: Constants.Colors.primaryText, icon: "antenna.radiowaves.left.and.right") { vc in
                print("Data collection")
            },
            Item(title: "Networking", color: Constants.Colors.primaryText, icon: "network") { vc in
                print("Networking")
            },
        ]),
        
        Section(title: "Policies" ,items: [
            Item(title: "Privacy policy", color: Constants.Colors.primaryText, icon: "checkerboard.shield") { vc in
                print("Privacy policy")
            },
            Item(title: "Terms and conditions", color: Constants.Colors.primaryText, icon: "newspaper") { vc in
                print("Terms and conditions")
            },
        ]),
        
        Section(title: "Account" ,items: [
            Item(title: "Logout", color: Constants.Colors.primaryText, icon: "arrow.uturn.left") { vc in
                let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "YES", style: .destructive) { alert in
                    guard let parentVC = vc.parent else {return}
                    UserModel.shared.logout(viewController: parentVC)
                })
                alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
                
                vc.present(alert, animated: true, completion: nil)
            },
            Item(title: "Delete account", color: .systemRed, icon: "trash.fill") { vc in
                print("Delete account")
            },
        ]),
        
        Section(title: "Premium" ,items: [
            Item(title: "Get premium membership", color: .systemYellow, icon: "crown.fill") { vc in
               print("Premium")
            },
            Item(title: "Become a V.I.P", color: .systemOrange, icon: "star.fill") { vc in
                print("VIP")
            },
        ]),
    ]
    
}
