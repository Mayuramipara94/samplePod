//
//  GroupDetailTabCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 29/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class GroupDetailTabCell: UITableViewCell {
    
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var lblDetails: UITextView!
    
    
    var arrCellData = [CellModel]()
    var reloadTable : (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        collection_view.register(UINib(nibName: "GroupDetailTabTitleCell", bundle: nil), forCellWithReuseIdentifier: "GroupDetailTabTitleCell")
        collection_view.delegate = self
        collection_view.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(model : CellModel) {
        
        arrCellData = model.dataArr as! [CellModel]
        collection_view.reloadData()
        setCurrentTabDetail()
    }
    
    func setCurrentTabDetail() {
        
        let filter = arrCellData.filter { (model) -> Bool in
            return model.isSelected
        }
        
        if let desc = filter.first?.userText,desc.count > 0 {
            
            if let arr = Utilities.objectFromJsonString(str: desc) as? [[String:Any]]{
                
                //link
                var arrTemp = [String]()
                for dict in arr{
                    
                    if let url = dict["url"] as? String{
                        
                        arrTemp.append(url)
                    }
                }
                
                lblDetails.text = arrTemp.joined(separator: "\n")
                
            }else{
                
                lblDetails.text = desc
                
            }
        }
        else{
            lblDetails.text = "No Detail"
        }
        
//        lblDetails.layoutIfNeeded()
        self.layoutIfNeeded()
    }
}

//MARK: UICollectionViewDataSource methods

extension GroupDetailTabCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (AppConstants.ScreenSize.SCREEN_WIDTH - 32)/3, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrCellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupDetailTabTitleCell", for: indexPath) as? GroupDetailTabTitleCell
        cell?.setCellData(model: arrCellData[indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for item in arrCellData {
            item.isSelected = false
        }
        
        arrCellData[indexPath.row].isSelected = true
        if let click = reloadTable {
            click()
        }
    }
}
