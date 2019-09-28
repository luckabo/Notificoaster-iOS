//
//  Session.swift
//  Notificoaster
//
//  Created by Scott Hetland on 2019-08-27.
//  Copyright © 2019 Scott Hetland. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class Session
{
    func login(email: String, password: String, completion: @escaping ([String: Any]) -> Void) -> Void
    {
        var login = [String: Any]()
        let urlString = Constants.baseURL + "/" + Constants.login
        let url = URL(string: urlString)
        
        var req = URLRequest(url: url!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        
        let json: [String: Any] = ["email": email,
                                   "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        req.httpBody = jsonData
        
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: req) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if (responseJSON as? [String: Any]) != nil {
                    login = responseJSON as! [String : Any]
                }
                completion(login)
            }
            task.resume()
        }
    }
    
    func fetchUserID() -> String
    {
        var userID = String()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                userID = results[0].value(forKey: "userID") as! String
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return userID
    }
    
    func fetchPhoneID() -> String
    {
        var phoneID = String()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                phoneID = results[0].value(forKey: "phoneID") as! String
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return phoneID
    }
    
    func updateTargetTemperature(targetTemp: Int, userID: String, completion: @escaping ([String: Any]) -> Void) -> Void
    {
        var updatedObject = [String: Any]()
        let urlString = Constants.baseURL + "/" + Constants.updateUser + userID
        let url = URL(string: urlString)
        
        var req = URLRequest(url: url!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "PATCH"
        
        let json: [String: Any] = ["targetTemperature": targetTemp]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        req.httpBody = jsonData
        
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: req) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if (responseJSON as? [String: Any]) != nil {
                    updatedObject = responseJSON as! [String : Any]
                }
                completion(updatedObject)
            }
            task.resume()
        }
    }
    
    func updatePhoneID(phoneID: Int, userID: String, completion: @escaping ([String: Any]) -> Void) -> Void
    {
        var updatedObject = [String: Any]()
        let urlString = Constants.baseURL + "/" + Constants.updateUser + userID
        let url = URL(string: urlString)
        
        var req = URLRequest(url: url!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "PATCH"
        
        let json: [String: Any] = ["phoneID": phoneID]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        req.httpBody = jsonData
        
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: req) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if (responseJSON as? [String: Any]) != nil {
                    updatedObject = responseJSON as! [String : Any]
                }
                completion(updatedObject)
            }
            task.resume()
        }
    }
    
    func save(deviceID: String, userID: String, targetTemp: Int, phoneID: String)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                results[0].setValue(targetTemp, forKey: "targetTemp")
            }
            else {
                let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
                let device = NSManagedObject(entity: entity, insertInto: managedContext)
                
                device.setValue(deviceID, forKey: "deviceID")
                device.setValue(userID, forKey: "userID")
                device.setValue(targetTemp, forKey: "targetTemp")
                device.setValue(phoneID, forKey: "phoneID")
            }

        } catch let error as NSError {
            print("Error fetching \(error)")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("could not save \(error)")
        }
    }
    
    func delete()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            for object in objects {
                managedContext.delete(object)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("could not delete \(error)")
        }
        UserDefaults.standard.removeObject(forKey: "phoneID")
    }
}
