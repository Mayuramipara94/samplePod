//
//  GroupLinkCell.swift
//  ConferenceAssociationApp
//
//  Created by CS-Mac-Mini on 08/02/19.
//  Copyright © 2019 CS-Mac-Mini. All rights reserved.
//

import UIKit

class GroupLinkCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var txtLink: UITextField!
    @IBOutlet weak var lblBorder: UILabel!
    
    var deleteModel : ((Int)->())?
    var model = CellModel()
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        txtLink.delegate = self
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(model:CellModel){
        
        self.model = model
        self.txtLink.text = model.userText
    }
    
    @IBAction func btnDelete_Click(_ sender: UIButton) {
        
        self.deleteModel?(self.index)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        model.userText = textField.text
    }
}
