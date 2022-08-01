//
//  FrameModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 04/07/2022.
//

import Foundation
import UIKit

struct FrameModel:Identifiable {
    let id = UUID().hashValue
    let container:UIStackView
    let videoView:UIView
    let buttonContainer:UIStackView
    let muteButton: UIButton
    var color: CGColor
    var uid:UInt {
        let uid = self.id < 0 ? self.id * -1 : self.id
        return UInt(uid)
    }
    mutating func setColor(color:CGColor) {
        self.color = color
    }
}
