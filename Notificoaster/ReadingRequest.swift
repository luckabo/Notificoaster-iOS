//
//  ReadingRequest.swift
//  Notificoaster
//
//  Created by Scott Hetland on 2019-01-15.
//  Copyright © 2019 Scott Hetland. All rights reserved.
//

import Foundation

class ReadingRequest
{
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()

    // Will be one function that upon request, returns an array of items with the last one being the most recent
    func getReadings(deviceId: String, completion: @escaping ([Reading]) -> Void) -> Void
    {
        var readings = [Reading]();
        
        var date = Date()
        date.addTimeInterval(TimeInterval(Constants.DataTableTimeInterval))
        let dateString = dateFormatter.string(from: date)
        
        let urlString = Constants.baseURL + "/" + Constants.request + "/" + deviceId + "/createdAt/" + dateString
        let url = URL(string: urlString)
    
        var req = URLRequest(url: url!)
        req.setValue(Constants.UrlHeader, forHTTPHeaderField: "Accept")
        
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
                guard let data = data else { return }
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data, options:[]) as? [Any] {
                        for object in dict {
                            if let tempDict = object as? [String: Any] {
                                let deviceId = tempDict["deviceID"] as! String
                                let temp = tempDict["temp"] as! Double
                                let createdAt = tempDict["createdAt"] as! String
                                
                                let tempRead = Reading(aDevice: deviceId, aCreatedAt: createdAt, aTemp: temp)
                                readings.append(tempRead)
                            }
                        }
                    }
                } catch let error as NSError {
                    print("No readings for device \(error)")
                }
                completion(readings)
            }
            task.resume()
        }
    }
}
