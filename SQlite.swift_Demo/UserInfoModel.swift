//
//  UserInfoModel.swift
//  SQlite.swift_Demo
//
//  Created by lidong on 2019/8/28.
//  Copyright © 2019年 macbook. All rights reserved.
//

import UIKit

class UserInfoModel: NSObject {
    var userId: String
    var userName: String
    var age: Int
    
    init(userId: String, userName: String, age: Int) {
        self.userId = userId
        self.userName = userName
        self.age = age
        super.init()
    }
}
