//
//  SettingsModel.swift
//  Convos
//
//  Created by Nitsan Asraf on 16/08/2022.
//

import UIKit

protocol SettingsProtocol: AnyObject {
    func openPrivacy()
    func logout()
    func deleteUser()
    func getPremium()
}

class SettingsModel {
    
    weak var delegate: SettingsProtocol?
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    struct Item {
        let title: String
        let color: UIColor
        let icon: String
        let function: () -> ()
    }
    
    lazy var sections = [
        Section(title: "Privacy" ,items: [
            Item(title: "Notifications", color: Constants.Colors.primaryText, icon: "bell.fill") {},
            Item(title: "Privacy policy", color: Constants.Colors.primaryText, icon: "checkerboard.shield") {
                self.delegate?.openPrivacy()
            },
        ]),
        
        Section(title: "Account" ,items: [
            Item(title: "Logout", color: Constants.Colors.primaryText, icon: "arrow.uturn.left") {
                self.delegate?.logout()
            },
            Item(title: "Delete account", color: .systemRed, icon: "trash.fill") {
                self.delegate?.deleteUser()
            }
        ]),
        
        Section(title: "Premium" ,items: [
            Item(title: "Get a premium membership", color: .systemYellow, icon: "crown.fill") {
                self.delegate?.getPremium()
            },
        ]),
    ]
}
