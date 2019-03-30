//
//  GroupDetailTabTitleCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 29/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class GroupDetailTabTitleCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCellData(model : CellModel) {
        
        lblTitle.text = model.placeholder
        viewLine.isHidden = !model.isSelected
    }
}
