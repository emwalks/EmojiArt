//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 07/10/2019.
//  Copyright © 2019 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//

import UIKit

class EmojiArtView: UIView, UIDropInteractionDelegate
{
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    // again adding accessibility change ability
    private var font: UIFont {
        return
            UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    // MARK: - UIDropInteractionDelegate
    
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            // this is the point the drop is
            let dropPoint = session.location(in: self)
            // if my cast is nil add empty array
            for attributedString in providers as? [NSAttributedString] ?? [] {
                self.addLabel(with: attributedString, centeredAt: dropPoint)
            }
        }
    }
    
    private func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        // next row is not in Demo
        label.attributedText = attributedString.font != nil ? attributedString : NSAttributedString(string: attributedString.string,attributes: [.font:self.font])
    //   label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        //these recognise taps, pinches etc to the emojis
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
    }
    
    // MARK: - Drawing the Background
    
    var backgroundImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
    
}
