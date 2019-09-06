//
//  LoginViewController.swift
//  Notificoaster
//
//  Created by Scott Hetland on 2019-08-26.
//  Copyright © 2019 Scott Hetland. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class LoginViewController: UIViewController
{
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var loginButton : UIButton!
    
    var deviceID : String = ""
    
    @objc func login(_ sender: AnyObject?)
    {
        Session().login(email: emailField.text!, password: passwordField.text!) { (login) in
            if login["deviceID"] != nil {
                self.deviceID = login["deviceID"] as! String
                Session().save(deviceID: self.deviceID)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showReadingViewController", sender: self)
                }
            }
            else {
                // TODO: write an error message to a label on the screen when login fails
                print("user not found")
            }
        }
    }
    
    
    // MARK: - UIViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showReadingViewController" {
            let backButton = UIBarButtonItem()
            backButton.title = "Logout"
            navigationItem.backBarButtonItem = backButton
            
            if let destinationVC = segue.destination as? ReadingViewController {
                destinationVC.deviceId = deviceID
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                deviceID = results[0].value(forKey: "deviceID") as! String
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showReadingViewController", sender: self)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Configure starting text and styling
        titleLabel.text = NSLocalizedString("LOGIN TITLE LABEL", comment: "")
        titleLabel.textColor = UIColor.white
        titleLabel.font = .titleFont
        emailField.placeholder = NSLocalizedString("LOGIN EMAIL FIELD PLACEHOLDER", comment: "")
        passwordField.placeholder = NSLocalizedString("LOGIN PASSWORD FIELD PLACEHOLDER", comment: "")
        loginButton.setTitle(NSLocalizedString("LOGIN BUTTON TITLE", comment: ""), for: .normal)
        loginButton.loginButtonStyling(font: .loginButtonFont, height: loginButton.frame.size.height)
        
        self.view.backgroundColor = .backgroundColor
        
        // Configure login button
        loginButton.addTarget(self, action: #selector(LoginViewController.login(_:)), for: .touchUpInside)
    }
}
