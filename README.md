# SQlite.swift
swift版的数据库

```
let userInfo: UserInfoModel = UserInfoModel(userId: "1", userName: "lidong1", age: 4)
let userInfo1: UserInfoModel = UserInfoModel(userId: "2", userName: "lidong2", age: 1)
let userInfo2: UserInfoModel = UserInfoModel(userId: "3", userName: "lidong3", age: 7)
let userInfo3: UserInfoModel = UserInfoModel(userId: "4", userName: "lidong4", age: 2)
let userInfo4: UserInfoModel = UserInfoModel(userId: "5", userName: "lidong5", age: 3)
let userInfo5: UserInfoModel = UserInfoModel(userId: "6", userName: "lidong6", age: 9)
DBUtil.util.saveUserInfo(userInfo)
DBUtil.util.saveUserInfo(userInfo1)
DBUtil.util.saveUserInfo(userInfo2)
DBUtil.util.saveUserInfo(userInfo3)
DBUtil.util.saveUserInfo(userInfo4)
DBUtil.util.saveUserInfo(userInfo5)
        
let allUsers = DBUtil.util.getAllUserInfo(filter: nil, select: [userid, username, age], order: [age.asc], limit: nil, offset: nil)
for user in allUsers {
    print("\(user.userId), \(user.userName), \(user.age)")
}
```
