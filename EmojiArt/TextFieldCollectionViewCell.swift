//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 21/04/2020.
//  Copyright © 2020 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!{
        didSet {
            textField.delegate = self
        }
    }
    
    var resignationHandler: (()-> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //here we want to resign becoming the first responder and add the emoji to the collection view
        //rather than going to find it and all that gubbins
        //we can call a closeure function when that occurs
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // by calling this function now when the user presses return the key oard will dissapear as the text field resigns as first responder
        textField.resignFirstResponder()
        return true
    }
}
