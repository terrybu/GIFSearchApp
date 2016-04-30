//
//  GIFNetworkingService.swift
//  TimeHopAssignment
//
//  Created by Terry Bu on 4/29/16.
//  Copyright © 2016 Terry Bu. All rights reserved.
//

import Foundation
import SwiftyJSON

class GIFNetworkingService {
    
    static let sharedService = GIFNetworkingService()
    
    func getTrendingImages(completion: (success: Bool, gifImagesArray: [GIFImage]?) -> Void) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC")!, completionHandler: { (data, response, error) -> Void in
            do{
                let str = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                let json = JSON(str)
                let jsonData = json["data"].arrayValue
                var resultGifImagesArray = [GIFImage]()
                for object:JSON in jsonData {
                    if let newGifURL = object["images"]["fixed_width"]["url"].string {
                        print(newGifURL)
                        let newGifImage = GIFImage(urlString: newGifURL)
                        if let width = object["images"]["fixed_width"]["width"].string, height = object["images"]["fixed_width"]["height"].string, slug = object["slug"].string {
                            newGifImage.width = width
                            newGifImage.height = height
                            newGifImage.slug = slug
                        }
                        resultGifImagesArray.append(newGifImage)
                    }
                    
                }
                completion(success: true, gifImagesArray: resultGifImagesArray)
            }
            catch {
                print("json error: \(error)")
                completion(success: false, gifImagesArray: nil)
            }
        })
        task.resume()
    }
    
    
    //      Alamofire.request(.GET, "http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC").responseJSON { (response) in
    //print(response.result.value)
    


}