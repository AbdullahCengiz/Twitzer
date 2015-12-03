//
//  TwitzerModels.swift
//  twitzer
//
//  Created by abdullah cengiz on 02/12/15.
//  Copyright © 2015 abdullah cengiz. All rights reserved.
//

import Foundation

class Twitz {
    //MARK: Variables
    let id:String!
    let url:String!
    let text:String!
    let date:String!
    let userName:String!
    let userProfileImage:String!
    let timeStamp:Double!

    //MARK: Functions
    init(id:String? = "0", url:String? = "Not Specified", text:String? = "0", date:String? = "0", userName:String? = "Not Specified", userProfileImage:String? = "Not Specified", timeStamp:Double? = 0){
        self.id = id
        self.url = url
        self.text = text
        self.date = date
        self.userName = userName
        self.userProfileImage = userProfileImage
        self.timeStamp = timeStamp
    }

}
