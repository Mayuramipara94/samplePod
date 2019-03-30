//
//  GroupLinkMainCell.swift
//  ConferenceAssociationApp
//
//  Created by CS-Mac-Mini on 08/02/19.
//  Copyright © 2019 CS-Mac-Mini. All rights reserved.
//

import UIKit

class GroupLinkMainCell: UITableViewCell {

    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblBorder: UILabel!
    //MARK: Variables
    var mainModel = CellModel()
    var reloadData:(()->())?

    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialConfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Private Methods
    func initialConfig(){
        
        selectionStyle = .none
        tableView.register(UINib(nibName: "GroupLinkCell", bundle: nil), forCellReuseIdentifier: "GroupLinkCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setCellData(model:CellModel){
        
        self.mainModel = model
        if let arr = self.mainModel.dataArr as? [CellModel],arr.count > 0{
            
            self.tableViewHeight.constant = CGFloat(arr.count * 40)
            lblBorder.isHidden = false
        }else{
            
            lblBorder.isHidden = true
            self.tableViewHeight.constant = 0
        }
        
        tableView.reloadData()
    }
    
    //MARK: Action
    @IBAction func btnAddLinks_Click(_ sender: UIButton) {
        
        for mm1 in self.mainModel.dataArr{
            let mm = mm1 as? CellModel ?? CellModel()
            if mm.userText == nil {
             
                Utilities.showAlertView(title: AppConstants.AppName, message: "Please enter link")
                return
            }
            else if !mm.userText!.isValidUrl(){
                
                Utilities.showAlertView(title: AppConstants.AppName, message: "Please enter valid link")
                return
            }
        }
        
        self.mainModel.dataArr.append(CellModel())
        self.reloadData?()
    }
    
}

//MARK: TableView Delegates & DataSource

extension GroupLinkMainCell : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.mainModel.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = self.mainModel.dataArr[indexPath.row] as? CellModel ?? CellModel()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupLinkCell") as? GroupLinkCell
        cell?.index = indexPath.row
        cell?.setCellData(model: model)
        cell?.deleteModel = { index in
            
            self.mainModel.dataArr.remove(at: index)
            self.reloadData?()
        }
        if indexPath.row == self.mainModel.dataArr.count - 1 {
            
            cell?.lblBorder.isHidden = true
        }else{
            
             cell?.lblBorder.isHidden = false
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
    }
}

