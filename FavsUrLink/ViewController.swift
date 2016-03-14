//
//  ViewController.swift
//  FavsUrLink
//
//  Created by Mattia Cantalù on 10/03/16.
//  Copyright © 2016 Mattia Cantalù. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView : UITableView!
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var email : String?
    private var linksArray : [Dictionary<String, String>]? = []
    private let userDefault = NSUserDefaults.standardUserDefaults()
    private let titleView : UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
        initNavigationItemTitleView()
        
        self.linksArray = self.userDefault.arrayForKey("linksArray") as? [Dictionary<String, String>]
        if ((self.linksArray) == nil) {
            self.linksArray = []
        }
        
        if (getEmail() == nil) {
            showEmailAlert()
        }
    }
    
    func shareMessage(messageDict : Dictionary<String,String>) {
        
        let content = NSKeyedArchiver.archivedDataWithRootObject(messageDict)
        let pubMessage: GNSMessage = GNSMessage(content: content)
        self.appDelegate.publication = self.appDelegate.messageManager.publicationWithMessage(pubMessage)
        
    }
    
    //MARK: - Setup
    private func setupTableView() {
        self.tableView.editing = false
        let addBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addAction")
        self.navigationItem.rightBarButtonItem = addBtn
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    private func initNavigationItemTitleView() {
        setNavBarTitle()
        self.titleView.numberOfLines = 2
        self.titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        self.titleView.textAlignment = NSTextAlignment.Center
        let width = self.titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        self.titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        self.navigationItem.titleView = self.titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: "showEmailAlert")
        self.titleView.userInteractionEnabled = true
        self.titleView.addGestureRecognizer(recognizer)
    }
    
    private func setNavBarTitle() {
        var barTitle : String = "Click to login"
        if ((getEmail()) != nil) {
            barTitle = NSString(format: "Logged\n %@", self.email!) as String
        }
        self.titleView.text = barTitle as String
    }
    
    //MARK: - Account
    private func saveEmail(email : String?) {
        appDelegate.email = email
        self.setNavBarTitle()
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func getEmail() -> String? {
        self.email = appDelegate.email
        if ((self.email) != nil && self.email != "") {
            return self.email
        }
        return nil
    }
    
    //MARK: - TableView Delegate & DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.linksArray!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath)
        
        let linkDict = self.linksArray![indexPath.row]
        cell.textLabel?.text = linkDict["kTitle"]
        cell.detailTextLabel?.text = linkDict["kRate"]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var dict = self.linksArray![indexPath.row]
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet);
        alert.addAction(UIAlertAction(title: "Rate!", style: UIAlertActionStyle.Destructive, handler: {(action:UIAlertAction) in
            
            let rate = Int(dict["kRate"]!)
            self.linksArray![indexPath.row]["kRate"] = "\(rate!+1)"
            self.syncData()
            self.shareMessage(self.linksArray![indexPath.row])
        }));
        alert.addAction(UIAlertAction(title: "Open in Safari", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            let svc = SFSafariViewController(URL: NSURL(string: dict["kUrl"]!)!)
            self.presentViewController(svc, animated: true, completion: nil)
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action:UIAlertAction) in
        }));
        
        presentViewController(alert, animated: true, completion: nil);
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            self.linksArray?.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            syncData()
        default:
            return
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if (self.tableView.editing == true) {
            self.tableView.editing = false
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        }
        else {
            self.tableView.editing = true
            self.navigationItem.leftBarButtonItem?.title = "Done"
        }
    }
    
    //MARK: - Misc
    private func syncData() {
        self.userDefault.setObject(self.linksArray, forKey: "linksArray")
        self.userDefault.synchronize()
        self.tableView.reloadData()
    }
    
    //Add link
    func addAction(){
        let alertController = UIAlertController(title: "Add link", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Buttons
        let confirm = UIAlertAction(
            title: "OK", style: UIAlertActionStyle.Default) {
                (action) -> Void in
                
                let title = ((alertController.textFields?[0])! as UITextField).text
                let url = ((alertController.textFields?[1])! as UITextField).text
                if url!.lowercaseString.rangeOfString("http://") == nil {
                    return
                }
                
                let dict : NSDictionary = NSDictionary(objects: [title!, url!, "0"], forKeys: ["kTitle", "kUrl", "kRate"])
                self.linksArray!.append(dict as! Dictionary<String, String>)
                self.syncData()
        }
        
        let cancel = UIAlertAction(
            title: "Cancel", style: UIAlertActionStyle.Cancel) {
                (action) -> Void in
        }
        
        //Text
        alertController.addTextFieldWithConfigurationHandler {
            (txtEmail) -> Void in
            txtEmail.placeholder = "Title"
        }
        
        alertController.addTextFieldWithConfigurationHandler {
            (txtEmail) -> Void in
            txtEmail.text = "http://"
        }
        
        alertController.addAction(confirm)
        alertController.addAction(cancel)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Account alert
    func showEmailAlert() {
        let alertController = UIAlertController(title: "Insert email", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let email = self.getEmail()
        
        //Buttons
        let login = UIAlertAction(
            title: "Login", style: UIAlertActionStyle.Default) {
                (action) -> Void in
                
                self.saveEmail(((alertController.textFields?[0])! as UITextField).text)
                self.appDelegate.startShareContext()
        }
        
        let logout = UIAlertAction(
            title: "Logout", style: UIAlertActionStyle.Destructive) {
                (action) -> Void in
                self.saveEmail(nil)
                self.appDelegate.stopShareContext()
        }
        
        let cancel = UIAlertAction(
            title: "Cancel", style: UIAlertActionStyle.Cancel) {
                (action) -> Void in
        }
        
        //Text
        alertController.addTextFieldWithConfigurationHandler {
            (txtEmail) -> Void in
            
            if (email != nil) {
                txtEmail.text = email
            }
            else {
                txtEmail.placeholder = "Email"
            }
        }
        
        if (email != nil) {
            alertController.addAction(logout)
            alertController.addAction(cancel)
        }
        else {
            alertController.addAction(login)
            alertController.addAction(cancel)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

