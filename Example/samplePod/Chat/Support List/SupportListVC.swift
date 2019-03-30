//
//  SupportListVC.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 06/12/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class SupportListVC: ListingBaseViewController {
    
    var arrGroupList = [GroupListModel]()
    var arrTemp = [GroupListModel]()
    var module : Int = AppConstants.ModuleConstant.SUPPORT

    override func viewDidLoad() {
        super.viewDidLoad()

        initialConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerForNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ChatManager.sharedInstance.attachmentsTable.removeAllObjects()
        Utilities.setNavigationBar(controller: self, isHidden: false, title: StringConstants.ScreenTitle.kSupport)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loadDataFromDb()
        }
    }
    
    func registerForNotifications() {
        NotificationCenter.default.removeObserver(self)
        
        // Thread Sync
        NotificationCenter.default.addObserver(self, selector: #selector(loadDataFromDb), name: NSNotification.Name(rawValue: ChatConstant.Notification.MessageReceived), object: nil)
    }
    
    //MARK: Private Methods
    func initialConfig() {
        
        //addBarButton()
        self.isShowTags = false
        self.isAddPullToRefresh = true
        self.isAddScrollToTopButton = false
        self.isShowSearchBar = true
        self.isAddPagination = false
        
        self.initBaseViewController()
        self.tableView?.register(UINib.init(nibName: "GroupListCell", bundle: nil), forCellReuseIdentifier: "GroupListCell")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.syncDB(isShowLoader: true)
        }
    }
    
    //Sync Data
    func syncDB(isShowLoader:Bool = false) {
        
        if isShowLoader{
            self.showCustomProgress(msg: ChatConstant.RefreshList)
        }
        ChatManager.sharedInstance.connect {
            ChatManager.sharedInstance.syncThread(module: AppConstants.ModuleConstant.SUPPORT) {
                
                self.dismissCustomProgress()
                self.loadDataFromDb()
            }
        }
        
        //offline
        self.loadDataFromDb()
    }
    
    //FetchData
    @objc func loadDataFromDb() {
        arrTemp = ChatManager.sharedInstance.fetchGroupWith(module: module)
        self.prepareDataSource()
    }
    
    func prepareDataSource() {
        arrGroupList.removeAll()
        arrGroupList = arrTemp
        self.reloadData()
    }
    
    //Reload Data
    func reloadData() {
        if arrGroupList.count == 0 {
            self.tableView?.loadNoDataFoundView(withMessage: StringConstants.NoDataMessage(module: AppConstants.ModuleConstant.CHAT_GROUP, moduleId: ""))
        }else {
            self.tableView?.removeLoadAPIFailedView()
        }
        self.tableView?.es.stopPullToRefresh()
        self.tableView?.reloadData()
    }
    
    //Referesh Data
    override func pullToRefresh() {
        self.syncDB()
    }
    
    //SearchBar
    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        if searchBar.text!.count != 0 {
            self.searchData(searchText: searchBar.text!)
        }
    }
    
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        self.prepareDataSource()
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text!.count != 0 {
            self.searchData(searchText: searchText)
        }else{
            self.prepareDataSource()
        }
    }
    
    func searchData(searchText:String){
        
        let filtered = self.arrTemp.filter({ (model) -> Bool in
            let tmp: NSString = model.title as NSString? ?? ""
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        arrGroupList.removeAll()
        arrGroupList = filtered
        self.reloadData()
    }
    
//    @objc func btnNotification_Click() {
//        let vc = NotificationListVC.init(nibName: "NotificationListVC", bundle: nil)
//        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
//    }
}

//MARK: TableView Delegates & DataSource

extension SupportListVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrGroupList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListCell") as! GroupListCell
        cell.module = self.module
        cell.setCellData(model: arrGroupList[indexPath.row])
        cell.reloadData = {
            
            self.syncDB()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = MMChatController(nibName: "MMChatController", bundle: nil)
        vc.threadId = arrGroupList[indexPath.row].id
        vc.referenceId = arrGroupList[indexPath.row].referenceId?.id
        vc.module   = module
        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
    }
}
