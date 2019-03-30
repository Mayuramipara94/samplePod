//
//  MMChatOutGoingCell.swift
//  Chat
//
//  Created by Coruscate on 06/10/17.
//  Copyright © 2017 Coruscate. All rights reserved.
//

import UIKit

class MMChatInCommingCell: MMChatCell {
    
    @IBOutlet var AvtarHeight: NSLayoutConstraint!
    @IBOutlet var AvtarWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.intialConfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func intialConfig() {

        self.AvtarWidth.constant  =  CGFloat(ChatConstant.Avtar.InCommingWidth)
        self.AvtarHeight.constant =  CGFloat(ChatConstant.Avtar.InCommingHeight)
    }
    
}
