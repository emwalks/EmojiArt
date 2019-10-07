//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 07/10/2019.
//  Copyright © 2019 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//

import UIKit

class EmojiArtView: UIView
{
    
    var backgroundImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
    
}
