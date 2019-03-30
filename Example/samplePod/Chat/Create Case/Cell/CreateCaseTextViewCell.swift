//
//  CreateCaseTextViewCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 22/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class CreateCaseTextViewCell: UITableViewCell {
    
    @IBOutlet weak var txtView: UIPlaceHolderTextView!
    
    var cellModel = CellModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        txtView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(model : CellModel) {
        
        cellModel           = model
        txtView.text        = model.userText
        txtView.placeholder = model.placeholder
    }
}

//MARK: textField delegate methods
extension CreateCaseTextViewCell : UITextViewDelegate{

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if range.location == 0{
            
            if text == " " {
                return false
            }
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        cellModel.userText = textView.text
    }
}
