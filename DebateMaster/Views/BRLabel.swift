//
//  BRLabel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/08/2022.
//

import UIKit

class BRLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(boldText bold: String, regularText regular: String, ofSize size:CGFloat, color: UIColor = Constants.Colors.primaryText ) {
        self.init(frame: .zero)
        let boldText = bold
        let boldAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: size)]
        let boldString = NSMutableAttributedString(string:boldText, attributes:boldAttrs)

        let normalText = regular
        let normalAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: size)]
        let normalString = NSMutableAttributedString(string:normalText, attributes: normalAttrs)

        boldString.append(normalString)
        
        self.attributedText = boldString
        self.textColor = color
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
