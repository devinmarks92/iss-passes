//
//  ISSPassesTableViewController.swift
//  iss-passes
//
//  Created by Devin Marks on 2/28/18.
//  Copyright © 2018 Devin Marks All rights reserved.
//

import UIKit

class ISSTableViewController: UITableViewController {
    
    var userLatitude : Double = 0.0
    var userLongitude : Double = 0.0
    
    var dataDictionay = [[String:Int]]()
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ISSTableViewCell", bundle: nil), forCellReuseIdentifier: "ISSTableViewCell")
        
        // set up activity indicator view
        activityIndicator.center = view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // get ISS data and reload tables on completion
        getPassesAsArray(latitude: userLatitude, longitude: userLongitude) { (dataDictionay) in
            self.dataDictionay = dataDictionay
            
            // finish UI tasks on main thread after callback
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
           
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDictionay.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ISSTableViewCell") as! ISSTableViewCell
        
            // format duration in minutes and seconds
            if let duration = dataDictionay[indexPath.row]["duration"] {
                let timeFormatter = DateComponentsFormatter()
                timeFormatter.allowedUnits = [.minute,.second]
                timeFormatter.unitsStyle = .short
                cell.durationLabel.text = timeFormatter.string(from: TimeInterval(duration))
            }
        
            // format date from ISS time interval
            if let risetime = dataDictionay[indexPath.row]["risetime"] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .long
                let date = Date(timeIntervalSince1970: Double(risetime))
                cell.risetimeLabel.text = dateFormatter.string(from: date)
            }
        
        return cell
    }

}
