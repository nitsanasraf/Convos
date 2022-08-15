//
//  FrameModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 04/07/2022.
//

import Foundation
import UIKit

struct FrameModel {
    var userUID: UInt? = nil
    let container = UIStackView()
    let videoView = UIView()
    let buttonContainer = UIStackView()
    let muteButton = UIButton()
    var color = UIColor.clear.cgColor
    
    mutating func setColor(color:CGColor) {
        self.color = color
    }
    
}
