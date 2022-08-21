//
//  KeyCenter.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 02/07/2022.
//

import Foundation

struct KeyCenter {
    static let appID = ProcessInfo.processInfo.environment["APP_ID"]!
    static let appCertificate = ProcessInfo.processInfo.environment["APP_CERTIFICATE"]!
}
