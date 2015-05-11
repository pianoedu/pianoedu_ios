//
//  TeacherViewControllerEx.swift
//  PianoEdu
//
//  Created by waklin on 15/4/22.
//  Copyright (c) 2015年 waklin. All rights reserved.
//

import UIKit
import Alamofire

class TeacherViewControllerEx: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var waitActivityIndicatorView : UIActivityIndicatorView!
    var token : String!
    var teacherHelper = TeacherHelper()
    
    @IBOutlet weak var conditionText: UITextField!
    @IBOutlet weak var teacherTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w : CGFloat = 100
        let h : CGFloat = 100
        let x = (self.view.bounds.width - w) / 2
        let y = (self.view.bounds.height - h) / 2
        waitActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(x, y, w, h))
        self.view.addSubview(waitActivityIndicatorView)
        waitActivityIndicatorView.hidesWhenStopped = true
        

        // Do any additional setup after loading the view.
        self.teacherTableView.delegate = self
        self.teacherTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.conditionText.text = "张"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? TeacherDetailViewController {
            dest.teacherDetail = sender as! TeacherDetail
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == teacherHelper.teachers.count {
            teacherHelper.fetch() {
                result in
                self.teacherTableView.reloadData()
            }
        }
        else {
            let teacher = self.teacherHelper.teachers[indexPath.row] as! NSDictionary
            let teacherId = teacher.valueForKey("teacher_id") as! String
            
            waitActivityIndicatorView.startAnimating()
            waitActivityIndicatorView.backgroundColor = UIColor.grayColor()
            teacherHelper.loadDetail(teacherId) {
                (result, teacherDetail) in
                switch result {
                case .Success:
                    self.waitActivityIndicatorView.stopAnimating()
                    self.performSegueWithIdentifier("teacherDetail", sender: teacherDetail)
                case .Failure(let reason):
                    println(reason)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = teacherHelper.teachers.count
        if teacherHelper.canFetch {
            rows += 1
        }
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("teacher", forIndexPath: indexPath) as! UITableViewCell
        
        if indexPath.row < teacherHelper.teachers.count {
            cell.textLabel!.textAlignment = NSTextAlignment.Left
            let teacher = self.teacherHelper.teachers[indexPath.row] as! NSDictionary
            cell.textLabel!.text = teacher.valueForKey("teacher_name") as? String
            let phone = teacher.valueForKey("phone") as! String
            cell.detailTextLabel!.text = "\(phone)"
        }
        else {
            cell.textLabel!.text = "加载更多..."
            cell.detailTextLabel!.text = " "
        }
        return cell
    }

    @IBAction func search(sender: UIButton) {
        
        self.teacherHelper.reload(self.conditionText.text) {
            result in
            if result {
                self.teacherTableView.reloadData()
            }
        }
    }
}
