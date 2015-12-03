//
//  TwitzerCommunicator.swift
//  twitzer
//
//  Created by abdullah cengiz on 02/12/15.
//  Copyright © 2015 abdullah cengiz. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import AFNetworking


//MARK: TriSettings
class TwitzerCommunicator:NSObject {
    //MARK: Variables
    var reach:Reachability!
    var baseURL = "http://176.58.126.236/twitzer/"
    var twitzsArray:[Twitz]!
    var isFirstRun = true

    class var sharedInstance :TwitzerCommunicator {
        struct Singleton {
            static let instance = TwitzerCommunicator()
        }

        return Singleton.instance
    }

    override init() {
        super.init()
        twitzsArray = []

        do {
            self.reach = try Reachability(hostname: "www.google.com")
        }
        catch {

        }
    }

    //MARK: Web Request Functions
    func fetchData() {

        // Remove old twitzs
        self.twitzsArray.removeAll(keepCapacity: false)

        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html") as? Set<NSObject>
        manager.requestSerializer.setValue("608c6c08443c6d933576b90966b727358d0066b4", forHTTPHeaderField: "X-Auth-Token")

        // AFNetworking can control that the device is connected to Internet but during implementation, I could not reach the server for a while. So I am checking server's availability as a double check
        if(reach.isReachable()){
            manager.GET(baseURL,
                parameters: nil,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    //Success
                    self.parseTwitzs(responseObject)
                },
                failure: { (operation: AFHTTPRequestOperation?, error: NSError?) in
                    //print(error!)
                    // trigger function in TwitzerMainVC
                    NSNotificationCenter.defaultCenter().postNotificationName("twitzsAreNotReady", object: nil)
                }
            )
        }
        else{
            //Server is not reachable. Warn user about it.
            NSNotificationCenter.defaultCenter().postNotificationName("twitzsAreNotReady", object: nil)

                if(isFirstRun){
                    TwitzerCommunicator.sharedInstance.warnUser(message: Constants.noInternetConnectionMessageInFirstRun)
                }
                else{
                    // Twitzs are loaded and user has an internet connection problem
                    TwitzerCommunicator.sharedInstance.warnUser(message: Constants.noInternetConnectionMessage)
                }


        }

    }

    //MARK: Parse Functions
    func parseTwitzs(responseObject:AnyObject){

        let json = JSON(responseObject)

        for currentObject in json {
            var isCorrupted = false
            let currentTwitzUrl = "\(currentObject.1["url"])"
            let currentTwitzId = "\(currentObject.1["id"])"
            var currentTwitzText = "\(currentObject.1["text"])"
            var currentTwitzDate = "\(currentObject.1["date"])"
            var currentTwitzUserName = "\(currentObject.1["user"])"
            let currentTwitzUserProfileImage = "\(currentObject.1["img"])"

            var currentTimeStamp:Double!
            if(currentTwitzDate != "null"){
                currentTimeStamp = ("\(currentObject.1["date"])" as NSString).doubleValue
            }
            else{
                currentTimeStamp = 0
            }

            // check current object corrupted or not
            if(currentTwitzUrl == "null" || currentTwitzId == "null" || currentTwitzText == "null" || currentTwitzDate == "null" || currentTwitzUserName == "null" || currentTwitzUserProfileImage == "null"){
                isCorrupted = true
            }


            // if date is not null, apply the date format.
            if(currentTwitzDate != "null"){
                currentTwitzDate = self.setDateFormat(currentTwitzDate)
            }


            // if text is not null, edit text for character limitation and clearing unwanted characters like
            if(currentTwitzText != "null"){
                currentTwitzText = self.editText(currentTwitzText)
            }

            //remove first character of username
            if(currentTwitzUserName != "null"){
                currentTwitzUserName = (currentTwitzUserName as NSString).substringWithRange(NSRange(location: 1, length: currentTwitzUserName.characters.count-1))
            }


            /*
            Actually "null" String should be a unique string. When I try to find corrupted data which I get from the response, for example a twitter user called "null" can be filtered at corrupted data. In this implementation I will not show the twitzs which are corrupted.
            */


            // if currentObject is not corrupted, create twitz object and add it to twitzArray
            if(!isCorrupted){
                let currentTwitz = Twitz(id: currentTwitzId, url: currentTwitzUrl, text: currentTwitzText, date: currentTwitzDate, userName: currentTwitzUserName, userProfileImage: currentTwitzUserProfileImage, timeStamp: currentTimeStamp)
                self.twitzsArray.append(currentTwitz)

            }
            else{
                print("*******************")
                print("*******************")
                print("Corrupted data !!")
                print("*******************")
                print("*******************")
                print("")
            }

        }

        // sort twitzs by date
        //self.twitzsArray.sortInPlace(self.sortTwitzs)

        self.twitzsArray.sortInPlace({ NSDate(timeIntervalSince1970:$0.timeStamp).compare(NSDate(timeIntervalSince1970:$1.timeStamp)) == NSComparisonResult.OrderedDescending })

        // trigger function in TwitzerMainVC
        NSNotificationCenter.defaultCenter().postNotificationName("twitzsAreReady", object: nil)


        // We fetched data. Splash screen is invisible now
        if(isFirstRun){
            isFirstRun = false
        }


    }

    //MARK: Helper Functions
    func sortTwitzs(this:Twitz, that:Twitz) -> Bool {
        return this.timeStamp < that.timeStamp
    }


    func setDateFormat(var date:String) -> String {

        let timeStamp = (date as NSString).doubleValue
        let twitzDate = NSDate(timeIntervalSince1970: timeStamp)

        let calendar = NSCalendar.currentCalendar()
        let twitzCalendercomponents = calendar.components([.Month, .Day, .Year], fromDate:twitzDate)
        let todaysCalenderComponents = calendar.components([.Month, .Day, .Year], fromDate:NSDate())


        let dateFormatter: NSDateFormatter = NSDateFormatter()
        let months = dateFormatter.monthSymbols
        let monthSymbol = (months[twitzCalendercomponents.month-1] as NSString).substringWithRange(NSRange(location: 0, length: 3))

        // is twitzDate today?
        if(todaysCalenderComponents.month == twitzCalendercomponents.month && todaysCalenderComponents.day == twitzCalendercomponents.day && todaysCalenderComponents.year == twitzCalendercomponents.year ){
            date = "Today"
        }
        else{
            date = "\(monthSymbol) \(twitzCalendercomponents.day)"
        }

        return date
    }

    func editText(var text:String) -> String{

        // for removing " lang=\"*\" data-aria-label-part=\"0\">" substring from text. * can be any language
        var splittedText = text.componentsSeparatedByString("\">")
        text = text.stringByReplacingOccurrencesOfString("\(splittedText[0])\("\">")", withString: "")

        // remove extra new line characters and white spaces from texts
        text = text.stringByReplacingOccurrencesOfString("\\s{2,}",withString: " ", options: .RegularExpressionSearch)

        // limit number of character
        if(text.characters.count > 140){
            text = (text as NSString).substringWithRange(NSRange(location: 0, length: 140))
        }

        return text
    }

    //MARK: UX Functions
    func warnUser(message message:String){

        print("in warnUser ")

        LNRSimpleNotifications.sharedNotificationManager.showNotification(Constants.errorString, body: message, callback: { () -> Void in
            LNRSimpleNotifications.sharedNotificationManager.dismissActiveNotification({ () -> Void in
                print("Notification dismissed")
            })
        })
    }



    func initWarningNotification(){

        LNRSimpleNotifications.sharedNotificationManager.notificationsPosition = LNRNotificationPosition.Bottom
        LNRSimpleNotifications.sharedNotificationManager.notificationsIcon = UIImage(named: "ErrorImage")
        LNRSimpleNotifications.sharedNotificationManager.notificationsBackgroundColor = UIColor.whiteColor()
        LNRSimpleNotifications.sharedNotificationManager.notificationsTitleTextColor = UIColor.redColor()
        LNRSimpleNotifications.sharedNotificationManager.notificationsBodyTextColor = UIColor.blackColor()
        LNRSimpleNotifications.sharedNotificationManager.notificationsSeperatorColor = UIColor.grayColor()
        LNRSimpleNotifications.sharedNotificationManager.notificationsDefaultDuration = 3

    }

}
