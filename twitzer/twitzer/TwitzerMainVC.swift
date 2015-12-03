//
//  TwitzerMainVC.swift
//  twitzer
//
//  Created by abdullah cengiz on 02/12/15.
//  Copyright © 2015 abdullah cengiz. All rights reserved.
//

// refreshControl tutorial which is followed : http://www.appcoda.com/custom-pull-to-refresh

import UIKit

class TwitzerMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {


    //MARK: Variables
    @IBOutlet var splashView: UIView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var twitzerIcon: UIImageView!
    var twitzsArray:[Twitz]!
    @IBOutlet var twitzTableView: UITableView!
    var refreshControl: UIRefreshControl!

    //MARK: VC Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()

        //add observer for request
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setData", name:"twitzsAreReady", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopLoading", name:"twitzsAreNotReady", object: nil)


        TwitzerCommunicator.sharedInstance.fetchData()

    }

    override func viewWillAppear(animated: Bool) {

    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    //MARK: UI Functions

    func initUI(){
        loadingIndicator.startAnimating()
        initTableView()
    }

    func hideSplashView(){
        twitzerIcon.alpha = 0
        UIView.animateWithDuration(2, delay: 3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            // Animation started
            self.splashView.alpha = 0
            self.twitzerIcon.alpha = 1
            }, completion: { finished in
                // Animation completed
                self.splashView.hidden = true
                self.loadingIndicator.stopAnimating()
        })

    }

    //MARK: Data Functions
    func setData(){

        if(refreshControl.refreshing){
            refreshControl.endRefreshing()
        }
        else{
            hideSplashView() // first run of app
        }

        twitzsArray = TwitzerCommunicator.sharedInstance.twitzsArray

        UIView.transitionWithView(self.twitzTableView,
            duration:0.35,
            options:UIViewAnimationOptions.TransitionFlipFromBottom,
            animations:
            { () -> Void in
               self.twitzTableView.reloadData()
            },
            completion: nil);


    }

    func stopLoading(){

        UIView.transitionWithView(self.twitzTableView,
            duration:0.35,
            options:UIViewAnimationOptions.TransitionCrossDissolve,
            animations:
            { () -> Void in
                if(self.refreshControl.refreshing){
                    self.refreshControl.endRefreshing()
                }
                else{
                    
                }
            },
            completion: nil);
    }

    //MARK: TableView Functions
    func initTableView(){
        twitzTableView.dataSource = self
        twitzTableView.delegate = self

        // init and add refreshcontrol
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.tintColor = UIColor.blackColor()
        twitzTableView.addSubview(refreshControl)


        if #available(iOS 8.0, *) {
            twitzTableView.estimatedRowHeight = 120
            twitzTableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(refreshControl.refreshing){
            TwitzerCommunicator.sharedInstance.fetchData()
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // gameHolder nill check
        if(twitzsArray == nil){
            return 0
        }
        else{
            return twitzsArray.count
        }

    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if #available(iOS 8.0, *) { // In IOS 8+, we can implement self sizing cells but for IOS 7 we need to calculate table cell heights.
            return UITableViewAutomaticDimension
        }
        else{

            let currentTwitz = twitzsArray[indexPath.row]

            // In table cell, 126 is the total width except twitzText. I calculated the height of label whose width is known. 50 is the total height of
            var heightForTwitzText = heightForLabel(text: currentTwitz.text, font: UIFont.systemFontOfSize(17), width: tableView.frame.width - 126) + 50

            if(heightForTwitzText < 120){
                heightForTwitzText = 120
            }

            return heightForTwitzText


        }


    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TwitzCell = tableView.dequeueReusableCellWithIdentifier("TwitzCell", forIndexPath: indexPath) as! TwitzCell
        let currentTwitz = twitzsArray[indexPath.row]

        //set values
        cell.twitzDateLabel.text = "- \(currentTwitz.date)"
        cell.twitzProfileNameLabel.text = "@\(currentTwitz.userName)"
        cell.twitzTextLabel.text = currentTwitz.text
        cell.twitzTextLabel.preferredMaxLayoutWidth = tableView.frame.width - 126
        cell.twitzProfileImageView.layer.cornerRadius = 4.0
        cell.twitzProfileImageView.layer.borderWidth = 1
        cell.twitzProfileImageView.layer.borderColor = UIColor.blackColor().CGColor
        cell.twitzProfileImageView.clipsToBounds = true
        cell.twitzProfileImageView.setImageForURL(currentTwitz.userProfileImage, placeholder: UIImage(named: "PlaceHolder"))

        cell.layoutIfNeeded()

        return cell
    }

    //MARK: Helper Functions
    func heightForLabel(text text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Left
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }



}

