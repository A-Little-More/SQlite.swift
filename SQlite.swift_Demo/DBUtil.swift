//
//  DBUtil.swift
//  SQlite.swift_Demo
//
//  Created by lidong on 2019/8/27.
//  Copyright © 2019年 macbook. All rights reserved.
//

import UIKit
import SQLite

let kCurrentUserId: String = "1"
let userid: Expression<String> = Expression<String>("userid")
let username: Expression<String> = Expression<String>("username")
let age: Expression<Int> = Expression<Int>("age")

class DBUtil: NSObject {

    static let util: DBUtil = DBUtil()
    
    private var db: Connection?
    private var table: Table?
    
    /// 获取数据库
    ///
    /// - Returns: 数据库
    func getDB() -> Connection {
        guard let db = self.db else {
            let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            self.db = try! Connection.init(filePath + "/user_data_cache.sqlite3")
            self.db?.busyTimeout = 5.0
            return self.db!
        }
        return db
    }
    
    /// 获取表
    ///
    /// - Returns: 表
    func getTable() -> Table {
        guard let table = self.table else {
            self.table = Table("userinfo")
            try! self.getDB().run(
                self.table!.create(temporary: false, ifNotExists: true, withoutRowid: true, block: { (builder) in
                    builder.column(userid)
                    builder.column(username)
                    builder.column(age)
                })
            )
            return self.table!
        }
        return table
    }
    
    /// 判断是否存在
    ///
    /// - Parameter userId: 用户id
    /// - Returns: 是否存在
    func isExist(userId: String) -> Bool {
        let query = self.getTable().filter(userid == userId)
        guard let result = try? self.getDB().prepare(query) else {
            return false
        }
        return Array(result).count > 0
    }
    
    /// 保存数据
    ///
    /// - Parameter userInfo: 数据
    func saveUserInfo(_ userInfo: UserInfoModel) {
        guard userInfo.userId != "" else { return }
        let isExist = self.isExist(userId: userInfo.userId)
        if !isExist {
            let insert = self.getTable().insert(
                userid <- userInfo.userId,
                username <- userInfo.userName,
                age <- userInfo.age)
            guard let rowId = try? self.getDB().run(insert) else {
                print("\(userInfo.userId)插入失败！！！")
                return
            }
            print("rowId == \(rowId)插入成功！！！")
        } else {
            let update = self.getTable().filter(userid == userInfo.userId).update(
                userid <- userInfo.userId,
                username <- userInfo.userName,
                age <- userInfo.age)
            guard let rowId = try? self.getDB().run(update) else {
                print("\(userInfo.userId)更新失败！！！")
                return
            }
            print("更新成功\(rowId)条")
        }
    }
    
    /// 删除指定用户
    ///
    /// - Parameter userId: 用户id
    func delete(userId: String) {
        guard userId != "" else { return }
        let isExist = self.isExist(userId: userId)
        if (isExist) {
            let query = self.getTable().filter(userid == userId)
            guard let count = try? self.getDB().run(query.delete()) else {
                print("\(userId)删除失败")
                return
            }
            print("成功删除了\(count)条数据")
        }
    }
    
    /// 清除所有数据
    func clearData() {
        guard let count = try? self.getDB().run(self.getTable().delete()) else {
            print("clearDataFailse")
            return
        }
        print("clearDataSucceed:\(count)条")
    }
    
    
    /// 根据指定的用户id查找用户
    ///
    /// - Parameter userId: 用户id
    /// - Returns: 用户信息
    func getUserInfo(userId: String) -> UserInfoModel? {
        guard userId != "" else { return nil }
        let isExist = self.isExist(userId: userId)
        if !isExist { return nil }
        let quert = self.getTable().filter(userid == userId)
        guard let result = try? self.getDB().prepare(quert) else { return nil }
        return result.map{
            UserInfoModel(userId: $0[userid], userName: $0[username], age: $0[age])
            }.first
    }
    
    
    
    /// 根据筛选条件获得所有用户数据
    ///
    /// - Parameters:
    ///   - filter: 筛选条件
    ///   - select: 字段信息
    ///   - order: 排序
    ///   - limit: 限制数量
    ///   - offset: 偏移量
    /// - Returns: 数据数组
    func getAllUserInfo(filter: Expression<Bool>? = nil, select: [Expressible] = [userid, username, age], order: [Expressible] = [userid.asc], limit: Int? = nil, offset: Int? = nil) -> [UserInfoModel] {
        var query = self.getTable().select(select).order(order)
        if let filter = filter {
            query = query.filter(filter)
        }
        if let limit = limit {
            if let offset = offset {
                query = query.limit(limit, offset: offset)
            } else {
                query = query.limit(limit)
            }
        }
        guard let result = try? self.getDB().prepare(query) else { return [] }
        return result.map{
            UserInfoModel(userId: $0[userid], userName: $0[username], age: $0[age])
        }
    }
    
}

// MARK: - 个人业务相关
extension DBUtil {
    
    
    /// 获得当前用户信息
    ///
    /// - Returns: 用户信息
    func myInfo() -> UserInfoModel? {
        guard let myUserId = UserDefaults.standard.value(forKey: kCurrentUserId) as? String else { return nil }
        return self.getUserInfo(userId: myUserId)
    }
    
    /// 当前用户的名字
    ///
    /// - Returns: 名字
    func myName() -> String? {
        guard let myUserInfo = self.myInfo() else { return nil }
        return myUserInfo.userName
    }
    
    /// 当前用户的年龄
    ///
    /// - Returns: 年龄
    func myAge() -> Int? {
        guard let myUserInfo = self.myInfo() else { return nil }
        return myUserInfo.age
    }
    
    /// 更新当前用户的名字
    ///
    /// - Parameter name: 名字
    func updateMyname(_ name: String) {
        guard let myUserInfo = self.myInfo() else { return }
        myUserInfo.userName = name
        self.saveUserInfo(myUserInfo)
    }
    
    /// 更新当前用户的年龄
    ///
    /// - Parameter age: 年龄
    func updateMyAge(_ age: Int) {
        guard let myUserInfo = self.myInfo() else { return }
        myUserInfo.age = age
        self.saveUserInfo(myUserInfo)
    }
    
}
