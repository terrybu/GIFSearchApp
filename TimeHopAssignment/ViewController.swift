//
//  ViewController.swift
//  TimeHopAssignment
//
//  Created by Terry Bu on 4/28/16.
//  Copyright © 2016 Terry Bu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var gifImagesArray = [GIFImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.center = view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC")!, completionHandler: { (data, response, error) -> Void in
            do{
                let str = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                let json = JSON(str)
                let jsonData = json["data"].arrayValue
                for object:JSON in jsonData {
                    if let newGifURL = object["images"]["fixed_width"]["url"].string {
                        print(newGifURL)
                        let newGifImage = GIFImage(urlString: newGifURL)
                        
                        if let width = object["images"]["fixed_width"]["width"].string, height = object["images"]["fixed_width"]["height"].string {
                            
                            newGifImage.width = width
                            newGifImage.height = height

                        }
                        
                        self.gifImagesArray.append(newGifImage)
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                    activityIndicator.stopAnimating()
                })
            }
            catch {
                print("json error: \(error)")
            }
        })
        task.resume()
    }
    
    //MARK: TableViewDataSource Protocol Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !gifImagesArray.isEmpty {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifImagesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TrendingTableViewCell
        
        let gifForRow = gifImagesArray[indexPath.row]
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
        //I used heightForRow to accomodate different height of the Gifs although they have "fixed width"
        let gifForRow = gifImagesArray[indexPath.row]
        if let n = NSNumberFormatter().numberFromString(gifForRow.height!) {
            let cgFloat = CGFloat(n)
//            print("this row has height of " + gifForRow.height!)
            return cgFloat
        }
        return 44 //default
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

