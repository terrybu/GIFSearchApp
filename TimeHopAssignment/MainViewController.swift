//
//  MainViewController.swift
//  TimeHopAssignment
//
//  Created by Terry Bu on 4/28/16.
//  Copyright © 2016 Terry Bu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var gifImagesArray: [GIFImage]?
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.center = view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        GIFNetworkingService.sharedService.getTrendingImages { (success, returnedImagesArray) in
            if success {
                self.gifImagesArray = returnedImagesArray
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                    activityIndicator.stopAnimating()
                })
            }
        }

    }
    
    //MARK: TableViewDataSource Protocol Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if gifImagesArray != nil {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifImagesArray!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TrendingTableViewCell
        
        let gifForRow = gifImagesArray![indexPath.row]
        cell.slugLabel.text = gifForRow.slug
        
        let imageURLString = gifForRow.urlString
//        print("width " + gifForRow.width!)
//        print("height " + gifForRow.height!)
        cell.tag = indexPath.row
        Alamofire.request(.GET, imageURLString).responseData { (response) in
            if let data = response.data {
                dispatch_async(dispatch_get_main_queue(),{
                    if cell.tag == indexPath.row {
                        cell.gifImageView.animateWithImageData(data)
                    }
                })
            }
        }
        return cell
    }
    
    //MARK: TableViewDelegate Protocol Methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //I used heightForRow to accommodate different heights of the Gifs while they have "fixed width"
        let gifForRow = gifImagesArray![indexPath.row]
        
        if let height = gifForRow.height {
            if let n = NSNumberFormatter().numberFromString(height) {
                let cgFloat = CGFloat(n)
                print("this row has height of " + height)
                return cgFloat
            }
        }
        return 44 //default
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
}

