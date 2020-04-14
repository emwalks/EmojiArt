//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 07/10/2019.
//  Copyright © 2019 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
    
    //by making the dropZone separate to the emoji art view we can keep track of what's being dropped in at the controller level but could be the same UIView
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    var emojiArtView = EmojiArtView()
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    var emojiArtBackgroundImage: UIImage? {
        get {
            return emojiArtView.backgroundImage
        }
        set {
            scrollView?.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    // MARK: - Collection View
    
    // here we map the collection (here of strings) and the map turns it into an array of strings where map iterates the closure over each element in the collection
    var emojis = "🍎🍊🌼☘️🦋🐠🌈☀️💧🍄🌸🌷🌻🌿🐿🦔🦚🦆🐝🐛".map { String($0) }
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet{
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    //this scales for accessibility settings from 64 pt
    //but need to set up the collection view to scale in size for this setting
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font:font])
            emojiCell.label.attributedText = text
        }
        return cell
    }
    
    //the collection view func has indexPAth already
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    //this function allows you drag multiple items
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    //here we are going to drag around NSAttributed strings
    //cell for item is like cell for row at in a table view
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        //here we get the NSAttributed string from the label you have selected (cellForItem) from the collection view
        //then we create a drag item with the item of type NSItemProvider that has a constructor where you can pass an object
        if let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            //if you are not dragging outside the app (local) then you don't need to worry about setting async stuff like in drop
            //less item provider stuff to deal with
            // just going to stash in local object
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            //if there has been a problem capturing the string don't set a drag item
            return []
        }
        
    }
    
    // this allows you to drop any attributed string
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    // here you set the intent - do you want to insert AT or insert into i.e. add a new one (insertAT) or replace current (insert into)
    // here if I am moving an existing emoji around in my collection view, I don't want to copy, I want to move
    // need to know if I am inside my own collection view
    // going to fix this in the items for begining by setting a local context, then here on drop do different ops depending on context
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = session.localDragSession?.localContext as? UICollectionView == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }

        //when we perform drop we need to update our model and the collection view
        //also dealing with 2 kinds of drop (external and internal)
    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
                //collectionViews' coordinator gives us all our info required for drop
                // this sets a default index path as (0, 0) if there isn't one
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    // If you are doing multiple adjustments to the model of a collection view or table view use the perform batch updates function to keep them in sync
                    collectionView.performBatchUpdates({
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    // this provides the animation
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                //here I am dealing with non-localised drag-drop
                //need to use a placeholder until you've received the data
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")
                )
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                     //this closure is not performed on the main queue, but has UI so need to dispatch to main q
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                        //if you error - can't get the attributedString then delete  the placeholder
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - DropZone
    
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
                self.emojiArtBackgroundImage = image
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
    
    
}
