//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 07/10/2019.
//  Copyright © 2019 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate
{
    //by making the dropZone separate to the emoji art view we can keep track of what's being dropped in at the controller level but could be the same UIView
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    //only want drags that have an image and a URL for that image
    //This whole thing is obj-c compatible and so it's a NSURL class
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    //we are allowing a copy to occur when the above is satisfied
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    var imageFetcher: ImageFetcher!
    
    //this says when the drag is finished allow the drop (copy) to occur
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async{
                self.emojiArtView.backgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            //this takes the first url in the (possibly multiple) drag group array
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { images in
            //we need to cast as the type of the array is an NSItemProvider
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
    
    @IBOutlet weak var emojiArtView: EmojiArtView!
    
}
