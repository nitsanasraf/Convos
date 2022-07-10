//
//  String+Extensions.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 10/07/2022.
//

import UIKit

extension String {
    func getColorByName() -> UIColor {
        switch self {
        case "white":
            return .white
        case "green":
            return .systemGreen
        case "cyan blue":
            return .systemCyan
        case "orange":
            return .orange
        case "vibrant yellow":
            return .systemYellow
        case "purple":
            return .systemPurple
        
        default:
            return .black
        }
    }
}
