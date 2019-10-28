//
//  File.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/13/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import CoreData

struct BasicPage: Decodable {
    let pageText: String
    let pageNumber: Int
    let imageUrl: String
}

class Page {
    
    let storyId: String
    let pageText: String
    let pageNumber: Int
    let imageUrl: String
    var pageImage: UIImage?
    var imageIsDownloaded: Bool
    
    init(storyId:String, pageText: String, pageNumber: Int, imageUrl: String, imageIsDownloaded: Bool) {
        self.storyId = storyId
        self.pageText = pageText
        self.pageNumber = pageNumber
        self.imageUrl = imageUrl
        self.imageIsDownloaded = imageIsDownloaded
    }
    
    init(dictionary: [String:Any]) {
        self.storyId = dictionary[C_STORYID] as! String
        self.pageText = dictionary[C_PAGETEXT] as! String
        self.pageNumber = dictionary[C_PAGENUMBER] as! Int
        self.imageUrl = dictionary[C_IMAGEURL] as! String
        self.imageIsDownloaded = false
    }

    

}
