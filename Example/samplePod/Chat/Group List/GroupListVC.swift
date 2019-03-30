//
//  GroupListVC.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 17/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class GroupListVC: ListingBaseViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var btnBottom: NSLayoutConstraint!
    
    //MARK: Variables
    //var isSyncCall = true
    var currentTab = TagsWithColorModel()
    
    var arrGroupList = [GroupListModel]()
    var arrTemp = [GroupListModel]()
    var moduleId  = ""
    var currentModuleModel = DeviceNavMenuSettings()
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        ChatManager.sharedInstance.attachmentsTable.removeAllObjects()
        Utilities.setNavigationBar(controller: self, isHidden: false, title: StringConstants.getScreenTitle(module: AppConstants.ModuleConstant.CHAT_GROUP, moduleId: moduleId))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView?.reloadData()
    }
    
    func registerForNotifications() {
        NotificationCenter.default.removeObserver(self)
        
        // Thread Sync
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageRecieved), name: NSNotification.Name(rawValue: ChatConstant.Notification.MessageReceived), object: nil)
    }

    //MARK: Private Methods
    func initialConfig() {
        
        //current Module
        self.currentModuleModel = SyncManager.sharedInstance.fetchNavMenusByNumberAndID(module: 0, moduleId: self.moduleId).first ?? DeviceNavMenuSettings()
        
        //Settings
        let moduleSetting = AppConfiguration.shared.getModuleSettingConfig(module: AppConstants.ModuleConstant.CHAT_GROUP, moduleId: moduleId)
        self.isShowTags = false
        self.isAddPullToRefresh = true
        self.isAddScrollToTopButton = false
        self.isShowSearchBar = moduleSetting.allow_search
        self.isAddPagination = false
        btnBottom.constant = (ApplicationData.AppSettings.is_bottom_banner_enable ? AppConstants.BannerSize.BottomBannerHeight : CGFloat(0))
        self.moduleBaseId = moduleId
        var isShow = true
        if currentModuleModel.code == AppConstants.ModuleCodeConstant.SELFIECORNER || ApplicationData.user.type == AppConstants.UserType.SUB_ADMIN || ApplicationData.user.type == AppConstants.UserType.ADMIN{
            
            isShow = false
        }else{
            
            isShow = AppConfiguration.shared.isCreateCaseEnable
        }
        self.isCreateCaseShow = isShow
        self.initBaseViewController()
        
        if currentModuleModel.code != AppConstants.ModuleCodeConstant.SELFIECORNER {
            //not register in selfie corner module
            registerForNotifications()
        }
        
        self.tableView?.register(UINib.init(nibName: "GroupListCell", bundle: nil), forCellReuseIdentifier: "GroupListCell")
        self.tableView?.register(UINib.init(nibName: "SelfieCornerListCell", bundle: nil), forCellReuseIdentifier: "SelfieCornerListCell")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
           // if self.isSyncCall{
                self.syncDB(isShowLoader: true)
            //}
        }
        
        if ApplicationData.user.type != AppConstants.UserType.SUB_ADMIN && ApplicationData.user.type != AppConstants.UserType.ADMIN && currentModuleModel.code == AppConstants.ModuleCodeConstant.SELFIECORNER{
            //selfie corner module
            configureFloatingbutton()
        }
    }

    private func configureFloatingbutton(){
        
        let floaty = Floaty()
        floaty.buttonColor = ColorConstants.ThemeColor
        floaty.plusColor = .white
        
        let item1 = FloatyItem()
        item1.buttonColor = ColorConstants.ThemeColor
        item1.title = "  Upload Photo  "
        item1.titleLabel.backgroundColor = ColorConstants.ThemeColor
        item1.titleLabel.font = FontScheme.kMediumFont(size: 16.0)
        item1.titleShadowColor = .clear
        item1.titleLabel.layer.cornerRadius = 5
        item1.titleLabel.clipsToBounds = true
        item1.icon = #imageLiteral(resourceName: "add_photo_Camera")
        item1.handler = { item in
            
            //photo
            
            DocumentPickerHelper.sharedInstance.openImagePicker()
            DocumentPickerHelper.sharedInstance.isDocumentGet = { (image, getDocument) in
                
                let model1 = UploadDocumentsModel()
                model1.image = image
                model1.fileDesc = ""
                model1.fileDate = DateUtilities.getIsoFormateCurrentDate()
                
                CreateGroupHelper.shared.uploadAttachment(model: model1, success: { (model) in
                    
                    let cellmodel = CellModel()
                    cellmodel.cellType = .CreateCaseMediaCell
                    cellmodel.dataArr = [model]
                    CreateGroupHelper.shared.createUpdateGroup(viewType: .CHAT_VIEW_TYPE_WALL, arrData: [cellmodel], groupModel: nil, tagId: self.currentTab.id, referenceId: nil) {
                        
                        self.syncDB()
                    }
                })
            }
        }
        floaty.addItem(item: item1)
        
        let item2 = FloatyItem()
        item2.buttonColor = ColorConstants.ThemeColor
        item2.title = "  Post Message  "
        item2.titleLabel.backgroundColor = ColorConstants.ThemeColor
        item2.titleLabel.font = FontScheme.kMediumFont(size: 16.0)
        item2.titleShadowColor = .clear
        item2.titleLabel.layer.cornerRadius = 5
        item2.titleLabel.clipsToBounds = true
        item2.icon = #imageLiteral(resourceName: "editWhite")
        item2.handler = { item in
            
            let vc = AddMessageWallVC(nibName: "AddMessageWallVC", bundle: nil)
            vc.tagId = self.currentTab.id
            vc.wallCreate = {
                
                self.syncDB()
               
            }
            UIViewController.current().navigationController?.pushViewController(vc, animated: true)
        }
        floaty.addItem(item: item2)
        
        super.view.addSubview(floaty)
    }
    
    //Sync Data
    func syncDB(isShowLoader:Bool = false) {
        
        if isShowLoader{
            self.showCustomProgress(msg: ChatConstant.RefreshList)
        }
        ChatManager.sharedInstance.connect {
            ChatManager.sharedInstance.syncThread(module: AppConstants.ModuleConstant.CHAT_GROUP) {
                
                self.dismissCustomProgress()
                self.loadDataFromDb()
                //if self.currentModuleModel.code == AppConstants.ModuleCodeConstant.SELFIECORNER {
                //selfie corner module
                if self.arrGroupList.count > 0{
                    
                    self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
                // }
                
            }
        }
        
        //offline
        self.loadDataFromDb()
    }

    
    //FetchData
    @objc func loadDataFromDb() {
        
        var type = ChatConstant.ViewType.CHAT_VIEW_TYPE_GROUP
        if self.currentModuleModel.code == AppConstants.ModuleCodeConstant.SELFIECORNER {
            //selfie corner module
            type = ChatConstant.ViewType.CHAT_VIEW_TYPE_WALL
        }
        arrTemp = ChatManager.sharedInstance.fetchGroupList(viewType: type, tagId: self.currentTab.id ?? "")
        self.prepareDataSource()
    }
    
    @objc func newMessageRecieved() {
        
        let type = ChatConstant.ViewType.CHAT_VIEW_TYPE_GROUP
        arrTemp = ChatManager.sharedInstance.fetchGroupList(viewType: type, tagId: self.currentTab.id ?? "")
        self.prepareDataSource()
        if self.arrGroupList.count > 0{
            
            self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    
    func prepareDataSource() {
        arrGroupList.removeAll()
        arrGroupList = arrTemp
        self.reloadData()
    }
    
    //Reload Data
    func reloadData() {
        if arrGroupList.count == 0 {
            
            self.tableView?.loadNoDataFoundView(withMessage: StringConstants.NoDataMessage(module: AppConstants.ModuleConstant.CHAT_GROUP, moduleId: self.moduleId))
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
            let tmp: NSString = model.title! as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        arrGroupList.removeAll()
        arrGroupList = filtered
        self.reloadData()
    }
    
    //MARK: IBAction
    @IBAction func btnCreateCase_Click(_ sender: UIButton) {
        
        let vc = CreateCaseVC(nibName: "CreateCaseVC", bundle: nil)
        vc.tagId = self.currentTab.id
        vc.groupCreateUpdate = {
            self.syncDB()
        }
        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: TableView Delegates & DataSource

extension GroupListVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrGroupList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if currentModuleModel.code == AppConstants.ModuleCodeConstant.SELFIECORNER {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelfieCornerListCell") as! SelfieCornerListCell
            cell.setCellData(model: arrGroupList[indexPath.row])
            cell.updateData = {
                
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListCell") as! GroupListCell
            cell.module = self.currentModuleModel.number
            cell.setCellData(model: arrGroupList[indexPath.row])
            cell.reloadData = {
                
                self.loadDataFromDb()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if currentModuleModel.code == AppConstants.ModuleCodeConstant.SELFIECORNER  {
            let vc = SelfieCornerDetailVC(nibName: "SelfieCornerDetailVC", bundle: nil)
            vc.model = arrGroupList[indexPath.row]
            UIViewController.current().navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = MMChatController(nibName: "MMChatController", bundle: nil)
            vc.threadId = arrGroupList[indexPath.row].id
            vc.referenceId = arrGroupList[indexPath.row].referenceId?.id
            vc.module   = AppConstants.ModuleConstant.CHAT_GROUP
            UIViewController.current().navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightsDictionary[indexPath] = cell.frame.size.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height =  self.cellHeightsDictionary[indexPath]{
            return height
        }
        return UITableViewAutomaticDimension
    }

}
