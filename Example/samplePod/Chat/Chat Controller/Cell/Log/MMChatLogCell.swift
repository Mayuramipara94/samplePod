//
//  MMChatLogCell.swift
//  EoMumbai
//
//  Created by Coruscate on 09/10/17.
//  Copyright © 2017 Coruscate's macmini. All rights reserved.
//

import UIKit

class MMChatLogCell: MMChatCell {
    
    @IBOutlet var centerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.centerView.layer.cornerRadius = 4.0
        self.centerView.layer.masksToBounds = true
//        self.centerView.backgroundColor = UIColor.init(red: 226/255, green: 235/255, blue: 244/255, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
