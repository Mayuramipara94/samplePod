//
//  MMChatOutGoingCell.swift
//  Chat
//
//  Created by Coruscate on 06/10/17.
//  Copyright © 2017 Coruscate. All rights reserved.
//

import UIKit

class MMChatOutGoingCell: MMChatCell {
    
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet var AvtarHeight: NSLayoutConstraint!
    @IBOutlet var AvtarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var deleteHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         self.intialConfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func intialConfig() {
        
        self.AvtarWidth.constant  =  CGFloat(ChatConstant.Avtar.OutGoingWidth)
        self.AvtarHeight.constant =  CGFloat(ChatConstant.Avtar.OutGoingHeight)
    }
    
    //Set Delete On Off
    func setDeleteOnOff(model : MessageModel ,isActiveselected : Bool) {
        
        btnDelete.isSelected = model.isSelected
        if isActiveselected,model.is_chat_message_deleted == false {
            self.deleteWidth.constant = 20
            self.deleteHeight.constant = 20
        }
        else{
            self.deleteWidth.constant = 0
            self.deleteHeight.constant = 0
        }
    }
}
