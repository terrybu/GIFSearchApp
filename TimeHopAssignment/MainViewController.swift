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

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    var gifImagesArray: [GIFImage]?
    var filteredGifResults = [GIFImage]()
    var searchController: UISearchController!
    var cache: NSCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureSearchController()
        
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
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        self.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    //MARK: TableViewDataSource Protocol Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if gifImagesArray != nil {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text?.characters.count > 0 {
            return filteredGifResults.count
        }
        
        return gifImagesArray!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TrendingTableViewCell
        cell.gifImageView.image = nil
        var gifForRow: GIFImage?
        
        if searchController.active && searchController.searchBar.text?.characters.count > 0 {
            gifForRow = filteredGifResults[indexPath.row]
        } else {
            gifForRow = gifImagesArray![indexPath.row]
        }
        
        cell.slugLabel.text = gifForRow!.slug
        cell.tag = indexPath.row
        let imageURLString = gifForRow!.urlString
        if cache.objectForKey("\(imageURLString)") != nil{
            let data = cache.objectForKey("\(imageURLString)") as! NSData
            cell.gifImageView.animateWithImageData(data)
        } else {
            Alamofire.request(.GET, imageURLString).responseData { (response) in
                if let data = response.data {
                    self.cache.setObject(data, forKey: "\(imageURLString)")
                    if cell.tag == indexPath.row {
                        dispatch_async(dispatch_get_main_queue(),{
                            cell.gifImageView.image = nil
                            cell.gifImageView.animateWithImageData(data)
                        })
                    }
                }
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
    
    //MARK: UISearchResultsUpdating Protocol
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print(searchController.searchBar.text)
        let filteredArray = gifImagesArray!.filter { (gif: GIFImage) -> Bool in
            return gif.slug!.lowercaseString.hasPrefix(searchController.searchBar.text!.lowercaseString)
        }
        filteredGifResults = filteredArray
        self.tableView.reloadData()
    }
}

