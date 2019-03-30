//
//  ExtensionClass.swift
//  PTE
//
//  Created by CS-Mac-Mini on 10/08/17.
//  Copyright © 2017 CS-Mac-Mini. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
extension UIBarButtonItem {
    
    func applyNavBarConstraints(width:CGFloat, height: CGFloat) {
        let currWidth = self.customView?.widthAnchor.constraint(equalToConstant: width)
        currWidth?.isActive = true
        let currHeight = self.customView?.heightAnchor.constraint(equalToConstant: height)
        currHeight?.isActive = true
    }
}

extension UIView{
    
    // before change any value check if it is used anywhere or not
    func addPageControl(count : Int, yOffSet:CGFloat = 20) -> UIPageControl{
        let frame = CGRect(x: 0, y: 0, width: CGFloat(count * 20), height: 20)
        let pageControl = UIPageControl.init(frame: frame)
        pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        pageControl.layer.cornerRadius = pageControl.frame.size.height/2
        pageControl.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - yOffSet)
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = count
        pageControl.hidesForSinglePage = true
        return pageControl
    }
}


//MARK: UIView IBInspactable
extension UIView {

    @IBInspectable
    var BackgroundColorKey: NSString   {
        
        get {
            return  "nil"
        }
        
        set {
            backgroundColor = ColorScheme.colorFromConstant(textColorConstant: newValue as String)
        }
    }
    
    @IBInspectable
    var TintColorKey: NSString   {
        
        get {
            return  "nil"
        }
        
        set {
            tintColor = ColorScheme.colorFromConstant(textColorConstant: newValue as String)
        }
    }
    
    @IBInspectable
    var BorderColorKey: NSString   {

        get {
            return  "nil"
        }

        set {
            layer.borderColor = ColorScheme.colorFromConstant(textColorConstant: newValue as String).cgColor
        }
    }
    
    @IBInspectable
    var CornerRadius: CGFloat   {
        
        get {
            return  0.0
        }
        
        set {
            layer.cornerRadius = newValue as CGFloat
        }
    }
    
    @IBInspectable
    var BorderWidth: CGFloat   {
        
        get {
            return  0.0
        }
        
        set {
            layer.borderWidth = newValue as CGFloat
        }
    }
    
    //MARK: giving corner from particular side
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat ,width : CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UILabel{
    
    @IBInspectable
    var TextColorKey: NSString   {
        
        get {
            return  "nil"
        }
        
        set {
            textColor = ColorScheme.colorFromConstant(textColorConstant: newValue as String)
        }
    }
    
    //MARK: Attaributes textColor change
    func ChangeColorofParticularCharatcerInString(array : NSArray, color : Array<Any>){
        let attrStr = NSMutableAttributedString(string:  self.text!)
        let inputLength = attrStr.string.count
        let searchString : NSArray = array
        let color = color
        for i in 0...searchString.count-1
        {
            
            let string : String = searchString.object(at: i) as! String
            let searchLength = string.count
            var range = NSRange(location: 0, length: attrStr.length)
            
            while (range.location != NSNotFound) {
                range = (attrStr.string as NSString).range(of: string, options: [], range: range)
                if (range.location != NSNotFound) {
                    attrStr.addAttribute(NSAttributedStringKey.foregroundColor, value: color[i], range: NSRange(location: range.location, length: searchLength))
                    range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
                    self.attributedText = attrStr
                }
            }
        }
    }
    
    //MARK: Read more
    
    func addTrailing(with trailingText: String, moreText: String) {
        
        let moreTextFont = FontScheme.kRegularFont(size: 12)
        let moreTextColor = ColorConstants.ThemeColor
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text!.count) - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        
        let trimmedForReadMore: String = (trimmedString as NSString).replacingCharacters(in: NSRange(location: ((trimmedString.count) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedStringKey.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedStringKey.font: moreTextFont, NSAttributedStringKey.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedStringKey.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedStringKey : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedStringKey : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
}

extension UIButton{
    
    @IBInspectable
    var TextColorKey: NSString   {
        
        get {
            return  "nil"
        }
        
        set {

            setTitleColor(ColorScheme.colorFromConstant(textColorConstant: newValue as String), for: .normal)
        }
    }
}



extension UITextField{
    
    @IBInspectable
    var PlaceHolderColorKey: NSString   {
        
        get {
            return  "nil"
        }
        
        set {
            
          self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: ColorScheme.colorFromConstant(textColorConstant: newValue as String)])
        }
    }
    
    @IBInspectable
    var TextColorKey: NSString   {
        
        get {
            return  "nil"
        }
        
        set {
            
            self.textColor = ColorScheme.colorFromConstant(textColorConstant: newValue as String)
        }
    }
}


typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint : CGPoint {
        return points.startPoint
    }
    
    var endPoint : CGPoint {
        return points.endPoint
    }
    
    var points : GradientPoints {
        get {
            switch(self) {
            case .topRightBottomLeft:
                return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1,y: 1))
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            }
        }
    }
}


extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    
    func DrawShadow()  {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero;
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOpacity = 0.5;
        self.layer.masksToBounds = false;
        self.clipsToBounds = false;
    }
  
    func dropShadow(scale: Bool = true) {
      self.layer.masksToBounds = false
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOpacity = 0.5
      self.layer.shadowOffset = CGSize(width: -1, height: 1)
      self.layer.shadowRadius = 1
      
      //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
      self.layer.shouldRasterize = true
      self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
  
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
      self.layer.masksToBounds = false
      self.layer.shadowColor = color.cgColor
      self.layer.shadowOpacity = opacity
      self.layer.shadowOffset = offSet
      self.layer.shadowRadius = radius
      //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
      self.layer.shouldRasterize = true
      self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // set Corner Radius
    func setCornerRadius(radius:CGFloat = 6)
    {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.layer.masksToBounds = true
    }
    
    // set Corner Radius
    func setBorderWidth(width : CGFloat)
    {
        self.layer.borderWidth = width
        self.layer.masksToBounds = true
    }
    
    // set Corner Radius
    func setBorderColor(color:UIColor)
    {
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
    }
    
//    // MARK: Show Confirmation Popup
//    func showConfirmationPopup(title: String,message:String,cancelButtonTitle:String, confirmButtonTitle:String,height : CGFloat,onConfirmClick: @escaping () -> (), onCancelClick: @escaping () -> ()){
//        
//        self.window?.rootViewController?.view.endEditing(true)
//        
//        let vc = ConfirmPopupVC(nibName: "ConfirmPopupVC", bundle: nil)
//        vc.headerTitle = title
//        vc.message = message
//        vc.cancelButtonTitle = cancelButtonTitle
//        vc.confirmButtonTitle = confirmButtonTitle
//        vc.confirmClicked = {
//            onConfirmClick()
//        }
//        
//        vc.cancelBtnClicked = {
//            onCancelClick()
//        }
//        
//        let formsheet : MZFormSheetController = MZFormSheetController(viewController: vc) as MZFormSheetController
//        formsheet.presentedFormSheetSize = CGSize(width: AppConstants.ScreenSize.SCREEN_WIDTH - 50, height: height)
//        formsheet.shadowRadius = 2.0
//        formsheet.shadowOpacity = 0.3
//        formsheet.shouldDismissOnBackgroundViewTap = false
//        formsheet.shouldCenterVertically = true
//        formsheet.cornerRadius = 5
//        formsheet.shouldDismissOnBackgroundViewTap = true
//        formsheet.transitionStyle = .bounce
//        
//        UIViewController.current().mz_present(formsheet, animated: true, completionHandler: nil)
//    }
//    
//    func loadAPIFailedView(onRefreshClick: @escaping () -> ()) {
//
//        self.window?.rootViewController?.view.endEditing(true)
//
//        let APIFailedView = Bundle.main.loadNibNamed("LoadAPIFailedView", owner: self, options: nil)?[0] as! LoadAPIFailedView
//        APIFailedView.message = "No Data Found"
//        APIFailedView.center = self.center
//        APIFailedView.btnRefreshClick = {()
//            onRefreshClick()
//        }
//
//
//       self.addSubview(APIFailedView)
//
//    }
//
    //MARK: Bottom  View
    func addBottomView() {
        
        let tabVW = Bundle.main.loadNibNamed("CommonBottomTabView", owner: self, options: nil)?[0] as! CommonBottomTabView
        var yPos = AppConstants.ScreenSize.SCREEN_HEIGHT - 50
        
        if #available(iOS 11.0, *) {
            
            yPos = yPos - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        tabVW.frame = CGRect.init(x: 0, y: yPos, width: AppConstants.ScreenSize.SCREEN_WIDTH, height: 50)
        //self.addSubview(tabVW)
        tabVW.tag = 1000001
        let wn = UIApplication.shared.keyWindow!
        wn.addSubview(tabVW)
    }
    
    //MARK: Bottom  View
    func removeBottomView() {
        
        let wn = UIApplication.shared.keyWindow!
        for view in wn.subviews{
            
            if view.tag == 1000001{
                
                view.removeFromSuperview()
            }
        }
    }
    
    func removeLoadAPIFailedView() {
      
        for vw in self.subviews{
            if let myvw = vw as? LoadAPIFailedView {
                myvw.removeFromSuperview()
            }
        }
        
    }

    func loadNoDataFoundView(withMessage:String,shouldShowButton:Bool = false, btnName:String = "Refresh",textColor:UIColor = ColorConstants.TextHeadingColor, onRefreshClick: (() -> ())? = nil) {
        
        //self.window?.rootViewController?.view.endEditing(true)
        
        let APIFailedView = Bundle.main.loadNibNamed("LoadAPIFailedView", owner: self, options: nil)?[0] as! LoadAPIFailedView
        
        APIFailedView.frame =  CGRect(x: 0, y: (self.bounds.size.height / 2) - 20, width: self.bounds.size.width, height: 40)
        APIFailedView.isShowRefreshButton = shouldShowButton
        APIFailedView.btnRefresh.setTitle("   \(btnName)   ", for: .normal)
        APIFailedView.message = withMessage
        APIFailedView.messageTextColor = textColor
//        APIFailedView.center = self.center
        APIFailedView.btnRefreshClick = {
            
            onRefreshClick?()
        }
        var isFound = false
        for vw in self.subviews{
            
            if vw is LoadAPIFailedView{
                
                isFound = true
            }
        }
        
        if !isFound{
            self.addSubview(APIFailedView)
        }
    }

    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 2.0) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.6
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = -5
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height+2
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            
            let attribute = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            let range = NSRange(location: 0, length: attribute.length)
            attribute.addAttribute(.foregroundColor, value: ColorConstants.TextColorLabel, range: range)
            attribute.addAttribute(.font, value: FontScheme.kRegularFont(size: 16), range: range)
            return attribute
        } catch {
            return NSAttributedString()
        }
    }
   
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIViewController{
    
    //MARK: Selection Popup
    func showSelectionPopup(topHeading: String?,isShowSearch : Bool = false, arrData:[SelectionPopupModel] = [], isAllSelect:Bool, isAllowMultipleSelection : Bool, isShowSelectAlloption : Bool = true, btnApplyTitle : String = "Done", btnCancelTitle : String = "Clear", onSubmitClick: @escaping ([SelectionPopupModel]) -> (), onClearClick : @escaping (() -> ())) {
        self.view.endEditing(true)
        
        let selectionPopup = SelectionPopup(nibName: "SelectionPopup", bundle: nil)
        
        selectionPopup.isShowSearchBar = isShowSearch
        selectionPopup.isAllowMultipleSelection = isAllowMultipleSelection
        selectionPopup.isShowSelectedImage = true
        selectionPopup.strHeading = topHeading
        selectionPopup.arrData = arrData
        selectionPopup.isAllSelect = isAllSelect
        selectionPopup.isShowSelectAlloption = isShowSelectAlloption
        
        selectionPopup.btnApplyTitle = btnApplyTitle
        selectionPopup.btnClearTitle = btnCancelTitle
        
        selectionPopup.didSelect = {(arrSelected) in
            
            onSubmitClick(arrSelected)
        }
        
        selectionPopup.didClearSelect = {
            onClearClick()
        }
        
        let formsheet : MZFormSheetController = MZFormSheetController(viewController: selectionPopup) as MZFormSheetController
        formsheet.presentedFormSheetSize = CGSize(width: AppConstants.ScreenSize.SCREEN_WIDTH, height: AppConstants.ScreenSize.SCREEN_HEIGHT)
        formsheet.shadowRadius = 2.0
        formsheet.shadowOpacity = 0.3
        formsheet.shouldDismissOnBackgroundViewTap = false
        formsheet.shouldCenterVertically = true
        formsheet.cornerRadius = 5
        formsheet.shouldDismissOnBackgroundViewTap = true
        formsheet.transitionStyle = .bounce
        
        self.mz_present(formsheet, animated: true, completionHandler: nil)
    }
    
    func showCustomProgress(msg:String){
        
        let q1 = CustomLoaderVC(nibName: "CustomLoaderVC", bundle: nil)
        q1.msg = msg
        let formsheet : MZFormSheetController = MZFormSheetController(viewController: q1) as MZFormSheetController
        formsheet.presentedFormSheetSize = CGSize(width: AppConstants.ScreenSize.SCREEN_WIDTH - 40, height: 70)
        formsheet.shadowRadius = 2.0
        formsheet.shadowOpacity = 0.3
        formsheet.shouldDismissOnBackgroundViewTap = false
        formsheet.shouldCenterVertically = true
        formsheet.cornerRadius = 5
        formsheet.shouldDismissOnBackgroundViewTap = true
        formsheet.transitionStyle = .fade
        self.mz_present(formsheet, animated: true, completionHandler: nil)
    }
    
    func dismissCustomProgress(){
        
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    func showLeftMenu(){
        
        let btnMenu = UIButton(frame : CGRect(x: 0, y: 0, width: 25, height: 25))
        btnMenu.setImage(#imageLiteral(resourceName: "menu-button"), for: .normal)
        btnMenu.addTarget(self, action: #selector(btnMenu_Click), for: .touchUpInside)
        btnMenu.tintColor = UIColor.white
        let menu = UIBarButtonItem(customView: btnMenu)
        self.navigationItem.setLeftBarButton(menu, animated: true)
    }
    
    @objc func btnMenu_Click(){
        
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}

extension UINavigationController{
    
    func popAllAndSwitch(to : UIViewController){
        
        self.setViewControllers([to], animated: true)
    }
}
