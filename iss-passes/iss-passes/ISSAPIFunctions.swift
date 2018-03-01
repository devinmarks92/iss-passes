//
//  ISSAPIFunctions.swift
//  iss-passes
//
//  Created by Devin Marks on 2/28/18.
//  Copyright © 2018 Devin Marks All rights reserved.
//

import Foundation
import UIKit

let NUM_PASS_RESULTS = 100
let API_ERROR = "There was a problem contacting the ISS API"

//  Display error messages
//  Grabs the topmost view controller and displays the message as an alert
func sendAlert(message: String) {
    if var viewedController = UIApplication.shared.keyWindow?.rootViewController {
        while let pViewController = viewedController.presentedViewController {
            viewedController = pViewController
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default, handler: nil))
        viewedController.present(alertController, animated: true, completion:nil)
    }
}

//  Get a json response from the ISS API passes function
//  Takes latitude/longitude and returns a JSON object containing a list of
//      future passes of the ISS over the given location
//
//  Returns nil on error
func getPassesAsJSON(latitude: Double, longitude: Double, completion: @escaping (Any?) -> ()) {
    if latitude < -80 || latitude > 80 {
        sendAlert(message: "Latitude must be between -80 and 80")
        completion(nil)
    } else if longitude < -180 || longitude > 180 {
        sendAlert(message: "Longitude must be between -180 and 180")
        completion(nil)
    } else {
        let url = URL(string: "http://api.open-notify.org/iss-pass.json?" +
            "lat=" + String(latitude) + "&lon=" + String(longitude) + "&n=" + String(NUM_PASS_RESULTS))
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error != nil {
                sendAlert(message: String.init(describing: error!.localizedDescription))
                completion(nil)
            } else {
                if let dat = try? JSONSerialization.jsonObject(with: data!, options: []) {
                    completion(dat)
                } else {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}

//  Get an array of passes from the ISS API passes function
//  Takes latitude/longitude and returns a list of dictionaries containing data on
//  future passes of the ISS over the given location
//
//  Returns an empty list on error
func getPassesAsArray(latitude: Double, longitude: Double, completion: @escaping ([[String:Int]]) -> ()) {
    getPassesAsJSON(latitude: latitude, longitude: longitude) { result in
        var ret = [[String:Int]]()
        if let resp = result as? [String:Any] {
            if let responses = resp["response"] as? [Any] {
                for object in responses {
                    if let obj = object as? [String: Int] {
                        ret.append(obj)
                    }
                }
            }
            if ret.count == 0 {
                sendAlert(message: API_ERROR)
            }
        }
        completion(ret)
    }
}

//  Get a json response from the ISS API current location function
//  Takes no arguments and gets a json object containing a dictionary containing
//  the current latitude and longitude of the ISS
//
//  Returns nil on error
func getCurrentAsJSON(completion: @escaping (Any?) -> ()) {
    let url = URL(string: "http://api.open-notify.org/iss-now.json")
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        if error != nil {
            sendAlert(message: String.init(describing: error!.localizedDescription))
                completion(nil)
        } else {
            if let dat = try? JSONSerialization.jsonObject(with: data!, options: []) {
                completion(dat)
            } else {
                completion(nil)
            }
        }
    }
    task.resume()
}

//  Get the latitude and longitude from the ISS API current location function
//  Takes no arguments and gets a string dictionary containing the current latitude and
//  longitude of the ISS
//
//  Returns an empty dictionary on error
func getCurrentAsDictionary(completion: @escaping ([String:String]) -> ()) {
    getCurrentAsJSON() { result in
        if let resp = result as? [String:Any] {
            if let responses = resp["iss_position"] as? [String:String] {
                completion(responses)
            } else {
                sendAlert(message: API_ERROR)
                completion([String:String]())
            }
        } else {
            completion([String:String]())
        }
    }
}

