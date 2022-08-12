//
//  UInt + Extensions.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 12/08/2022.
//

import Foundation

extension UInt {
    static func parse(from string: String) -> UInt? {
        let numberStr = (string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        return UInt(numberStr[..<numberStr.index(numberStr.startIndex, offsetBy: 9)])
    }
}
