//
//  LoginViewController.swift
//  PianoEdu
//
//  Created by waklin on 15/4/5.
//  Copyright (c) 2015年 waklin. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    var waitActivityIndicatorView : UIActivityIndicatorView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func tapLoginButton(sender: AnyObject) {
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        let loginUrl = "http://115.28.43.93/demo/lsmessage_test/index.php/c_login/check_user"
        let parameters : [String : AnyObject] = ["user_name":username, "password":password, "log_machine":1]
        
        waitActivityIndicatorView.startAnimating()
        waitActivityIndicatorView.backgroundColor = UIColor.grayColor()
        
        Login.sharedInstance.login(username, password: password) {
            result in
            
            switch result {
            case .Success:
                // 关闭自身
                self.dismissViewControllerAnimated(true, completion: nil)
            case .Failure(let reason):
                var alert = UIAlertView(title: nil, message: reason, delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
            
            self.waitActivityIndicatorView.stopAnimating()
        }
    }
    
    @IBAction func tapBackground(sender: UIView) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.usernameTextField.text = "周丹"
        self.passwordTextField.text = "12345678"
        
        let w : CGFloat = 100
        let h : CGFloat = 100
        let x = (self.view.bounds.width - w) / 2
        let y = (self.view.bounds.height - h) / 2
        waitActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(x, y, w, h))
        self.view.addSubview(waitActivityIndicatorView)
        waitActivityIndicatorView.hidesWhenStopped = true
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

}
