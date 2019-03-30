//
//  SelfieCornerDetailVC.swift
//  ConferenceAssociationApp
//
//  Created by CS-MacSierra on 28/12/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class SelfieCornerDetailVC: UIViewController {
    
    // MARK: - Variables
    var model:GroupListModel?
    
    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var lblLike: UILabel!
    @IBOutlet var btnComment: UIButton!
    @IBOutlet var lblComment: UILabel!
    
    // MARK: - View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        Utilities.setNavigationBar(controller: self, isHidden: false, title: "")
        
        self.setData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    //MARK: Private Methods
    func initialConfig() {
        
        addBackButton()
        
        self.tableView.register(UINib.init(nibName: "SelfieCornerDetailCell", bundle: nil), forCellReuseIdentifier: "SelfieCornerDetailCell")
        
    }
    
    private func addBackButton() {
        
        //Back
        let btnBack = UIButton(frame : CGRect(x: 0, y: 0, width: 22, height: 22))
        btnBack.setImage(#imageLiteral(resourceName: "closeWhite"), for: .normal)
        btnBack.tintColor = UIColor.white
        btnBack.addTarget(self, action: #selector(btnClose_Click(sender:)), for: .touchUpInside)
        
        let back = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButton(back, animated: true)
    }
    
    func setData(){
        
        lblLike.text = "\(model?.likesCount ?? 0)"
        lblComment.text = "\(model?.commentsCount ?? 0)"
        
        if model?.isLike == ChatConstant.LikeConstant.Like {
            btnLike.isSelected = true
        }
        else {
            btnLike.isSelected = false
        }
    }
    
    //MARK: - IBActions
    @objc func btnClose_Click(sender:UIButton){
        
        UIViewController.current().navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLikeClicked(_ sender: UIButton) {
        
        GroupListModel.callAPIForLikeDislike(module: AppConstants.ModuleConstant.CHAT_GROUP, model: self.model ?? GroupListModel()) {
            
            self.setData()
        }
    }
    
    @IBAction func btnCommentClicked(_ sender: UIButton) {
        
        let vc = MMChatController(nibName: "MMChatController", bundle: nil)
        vc.threadId = self.model?.id
        vc.referenceId = self.model?.referenceId?.id
        vc.module   = AppConstants.ModuleConstant.CHAT_GROUP
        vc.isSelfieCorner = true
        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
       
    }
   
}

//MARK: TableView Delegates & DataSource

extension SelfieCornerDetailVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (model != nil) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelfieCornerDetailCell") as! SelfieCornerDetailCell
        cell.setCellData(model: model!)
        return cell
    }
}
