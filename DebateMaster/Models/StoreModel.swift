//
//  StoreModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 12/09/2022.
//

import Foundation
import StoreKit

struct StoreModel {
    static var products = [SKProduct]()
    
    enum Products: String, CaseIterable {
        case premium = "com.nitsanasraf.ads"
    }
}
