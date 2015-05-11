//
//  Module.swift
//  PianoEdu
//
//  Created by waklin on 15/4/23.
//  Copyright (c) 2015年 waklin. All rights reserved.
//

import Foundation
import Alamofire

enum LoginResult {
    case Success
    case LoginInfoError
    case NetworkError
}

enum RequestResult {
    case Success
    case Failure(reason: String)
}

class Login {
    
    var userName : String?
    var password : String?
    var userId: String?
    var token : String?
    
    static var sharedInstance = Login()
    
    var logined : Bool {
        if let id = self.userId, t = self.token {
            return true
        }
        return false
    }
    
    func login(userName: String, password: String, handle: (result:RequestResult) -> Void) {
        
        let loginUrl = "http://115.28.43.93/demo/lsmessage_test/index.php/c_login/check_user"
        let parameters : [String : AnyObject] = ["user_name":userName, "password":password, "log_machine":1]
        
        Alamofire.request(.POST, loginUrl, parameters: parameters)
            .responseJSON { (_, _, JSON, error) in
                
                if let e = error {
                    handle(result: .Failure(reason: "网络不给力"))
                    return
                }
                
                let jsonData = JSON as! NSDictionary
                let check_login = jsonData["check_login"] as! String
                
                if check_login == "ok" {
                    self.userId = jsonData["user_id"] as? String
                    self.token = jsonData["token"] as? String
                    
                    handle(result: .Success)
                    self.userName = userName
                    self.password = password
                }
                else {
                    handle(result: .Failure(reason: "帐号或密码错误，请重新填写。"))
                }
        }
    }
}

class TeacherDetail {
    var name: String?
    var sex: String?
    var degree: String?
    var level: String?
    var major: String?
    var phone: String?
    var proportion: String?
    var company: String?
    var graduate: String?
}

class TeacherHelper {
    
    var keyword = ""
    var totalCount = 0
    var teachers = Array<AnyObject>()
    let numsPerFetch = 10
    
    var canFetch : Bool {
        get {
            return totalCount > self.teachers.count
        }
    }
    
    func fetch(completionHandler:(Bool)->Void) {
        let begin = self.teachers.count
        let offset = self.numsPerFetch
        self._request(begin: begin, offset: offset) {
            (teachers, totalCount) in
            for t in teachers {
                self.teachers.append(t)
            }
            self.totalCount = totalCount
            completionHandler(true)
        }
    }
    
    func reload(teacherKeyword:String, completionHandler:(Bool)->Void) {
        self.keyword = teacherKeyword
        
        let begin = 0
        let offset = self.numsPerFetch
        self._request(begin: begin, offset: offset) {
            (teachers, totalCount) in
            self.teachers = teachers
            self.totalCount = totalCount
            
            completionHandler(true)
        }
    }
    
    func loadDetail(teacherId: String, completionHandler:(RequestResult, TeacherDetail?)->Void) {
        let url = "http://115.28.43.93/demo/lsmessage_test/index.php/c_teacher/query_teacher_detail"
        let parameters : [String:AnyObject] = ["token": Login.sharedInstance.token!, "teacher_id":teacherId]
        
        Alamofire.request(.POST, url, parameters: parameters).responseJSON {
            
            (_, _, JSON, error) in
            if let e = error {
                completionHandler(.Failure(reason: "网络不给力"), nil)
                return
            }
            let jsonData = JSON as! NSDictionary
            let status = jsonData["status"] as! String
            if status == "ok" {
                
                var teacherDetail = TeacherDetail()
                teacherDetail.name = jsonData["teacher_name"] as? String
                teacherDetail.sex = jsonData["sex"] as? String
                teacherDetail.degree = jsonData["degree"] as? String
                teacherDetail.level = jsonData["level_name"] as? String
                teacherDetail.major = jsonData["major_name"] as? String
                teacherDetail.phone = jsonData["phone"] as? String
                teacherDetail.proportion = jsonData["proportion"] as? String
                teacherDetail.company = jsonData["company"] as? String
                teacherDetail.graduate = jsonData["graduate"] as? String
                
                completionHandler(.Success, teacherDetail)
            }
            else {
                completionHandler(RequestResult.Failure(reason: "token认证失败"), nil)
            }
        }
        
    }
    
    func _request(# begin:Int, offset:Int, completionHandler:(teachers: Array<AnyObject>, totalCount: Int)->Void) {
        
        let url = "http://115.28.43.93/demo/lsmessage_test/index.php/c_teacher/query_teacher"
        let parameters : [String:AnyObject] = ["token": Login.sharedInstance.token!, "teacher_name":self.keyword, "begin":begin, "offset":offset]
        
        Alamofire.request(.POST, url, parameters: parameters)
            .responseJSON { (_, _, JSON, _) in
                
                let jsonData = JSON as! NSDictionary
                
                let status = jsonData["status"] as! String
                if status == "ok" {
                    let totalCount = (jsonData["total_count"] as! String).toInt()!
                    let teachers = jsonData["query_teacher"] as! Array<AnyObject>
                    completionHandler(teachers: teachers, totalCount: totalCount)
                }
        }
    }
    
}

class RequestHelper<T> {
    var url : String
    var detailUrl : String
    var datas = [T]()
    var numsPerFetch : Int
    
    var condition : [String:String]!
    var total = Int.max
    
    init(url:String, detailUrl:String) {
        self.url = url
        self.detailUrl = detailUrl
        self.numsPerFetch = 10
    }
    
    var canFetch : Bool {
        get {
            return total > self.datas.count
        }
    }
    func fetch(completionHandler:(Bool)->Void){
        
    }
    
    func reload(condition:[String:String], completionHandler:(Bool)->Void) {
        
    }
}
