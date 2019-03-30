//
//  CreateCaseMediaCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 22/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class CreateCaseMediaCell: UITableViewCell {
    
    @IBOutlet weak var lblMedia: UILabel!
    @IBOutlet weak var collection_View: UICollectionView!
    @IBOutlet weak var heightCollection: NSLayoutConstraint!
    
    var arrAttachments = [UploadDocumentsModel]()
    var isAllowDelete = false
    var deletedIndex : ((_ index : Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        collection_View.register(UINib(nibName: "CaseImageCell", bundle: nil), forCellWithReuseIdentifier: "CaseImageCell")
        collection_View.delegate = self
        collection_View.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(model : CellModel,isAllowDelete : Bool) {
        
        self.isAllowDelete = isAllowDelete
        if model.dataArr.count > 0 {
            arrAttachments = model.dataArr as! [UploadDocumentsModel]
            lblMedia.isHidden = false
            heightCollection.constant = 150
        }
        else{
            lblMedia.isHidden = true
            heightCollection.constant = 0
        }
        
        collection_View.reloadData()
    }
    
    @IBAction func btnDelete_Click(_ sender: UIButton) {
        
        arrAttachments.remove(at: sender.tag)
        collection_View.reloadData()
        
        if let click = deletedIndex {
            click(sender.tag)
        }
    }
}

//MARK: UICollectionViewDataSource methods

extension CreateCaseMediaCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrAttachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CaseImageCell", for: indexPath) as? CaseImageCell
        cell?.setCellData(model: arrAttachments[indexPath.row])
        cell?.btnDelete.isHidden = !isAllowDelete
        cell?.btnDelete.tag = indexPath.row
        cell?.btnDelete.addTarget(self, action: #selector(self.btnDelete_Click(_:)), for: .touchUpInside)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = ImagecropVC(nibName: "ImagecropVC", bundle: nil)
        vc.arrAttachments = arrAttachments
        vc.isAllowEdit = false
        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
    }
}
