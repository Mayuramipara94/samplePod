//
//  CreateCaseTitleCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 22/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class CreateCaseTitleCell: UITableViewCell {
    
    @IBOutlet weak var txtField: UITextField!
    
    var cellModel = CellModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        txtField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(model : CellModel) {
        
        cellModel = model
        txtField.placeholder = model.placeholder
        txtField.text        = model.userText
    }
    
}

//MARK: textField delegate methods
extension CreateCaseTitleCell : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0{
            
            if string == " " {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        cellModel.userText = textField.text
    }
}
