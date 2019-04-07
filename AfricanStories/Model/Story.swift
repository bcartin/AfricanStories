//
//  Story.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/12/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import CoreData
import Firebase

struct BasicStory: Decodable {
    let ageGroup1 : Bool
    let ageGroup2 : Bool
    let ageGroup3 : Bool
    let androidStoryId : String
    let author : String
    let content : [String]
    let coverImageUrl : String
    let creativeDirector : String
    let demoImage1Url : String
    let demoImage2Url : String
    let demoImage3Url : String
    let editor : String
    let illustrator : String
    let purchased : Bool
    let song : String
    let storyId : String
    let summary : String
    let title : String
    let totalPages : Int
}

class Story {
    
    let storyId: String
    let title: String
    let purchased: Bool
    let summary: String
    let totalPages: Int
    let ageGroup1: Bool
    let ageGroup2: Bool
    let ageGroup3: Bool
    let coverImageUrl: String
    let demoImage1Url: String
    let demoImage2Url: String
    let demoImage3Url: String
    var author: String
    var editor: String
    var illustrator: String
    var creativeDirector: String
    let song: String
    var coverImage: UIImage?
    var demoImage1: UIImage?
    var demoImage2: UIImage?
    var demoImage3: UIImage?
    var content: String
    
    var pages = [Page]()
    
    init(storyDictionary: [String:Any]) {
        self.storyId = storyDictionary[C_STORYID] as! String
        self.title = storyDictionary[C_TITLE] as! String
        self.purchased = storyDictionary[C_PURCHASED] as! Bool
        self.summary = storyDictionary[C_SUMMARY] as! String
        self.totalPages = storyDictionary[C_TOTALPAGES] as! Int
        self.ageGroup1 = storyDictionary[C_AGEGROUP1] as! Bool
        self.ageGroup2 = storyDictionary[C_AGEGROUP2] as! Bool
        self.ageGroup3 = storyDictionary[C_AGEGROUP3] as! Bool
        self.author = storyDictionary[C_AUTHOR] as! String
        self.editor = storyDictionary[C_EDITOR] as! String
        self.illustrator = storyDictionary[C_ILLUSTRATOR] as! String
        self.creativeDirector = storyDictionary[C_CREATIVEDIRECTOR] as! String
        self.song = storyDictionary[C_SONG] as! String
        self.coverImageUrl = storyDictionary[C_COVERIMAGEURL] as? String ?? ""
        self.demoImage1Url = storyDictionary[C_DEMOIMAGE1URL] as? String ?? ""
        self.demoImage2Url = storyDictionary[C_DEMOIMAGE2URL] as? String ?? ""
        self.demoImage3Url = storyDictionary[C_DEMOIMAGE3URL] as? String ?? ""
        let contentArray = storyDictionary[C_CONTENT] as! [String]
        self.content = contentArray.joined(separator: ",")
    }
    
    func loadPagesFromCoreData(completion: @escaping(_ error: Error?) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {return}
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_PAGES)
            request.predicate = NSPredicate(format: "storyId = %@", self.storyId)
            request.returnsObjectsAsFaults = false
            do {
                let results = try managedContext.fetch(request)
                if results.count > 0 {
//                    var count = 1
                    results.forEach { (result) in
                        let object = result as! NSManagedObject
                        guard let storyId = object.value(forKey: C_STORYID) as? String else {return}
                        guard let pageNumber = object.value(forKey: C_PAGENUMBER) as? Int else {return}
                        guard let pageText = object.value(forKey: C_PAGETEXT) as? String else {return}
                        guard let imageData = object.value(forKey: C_PAGEIMAGE) as? Data else {return}
                        let pageImage = UIImage(data: imageData)
                        let page = Page(storyId: storyId, pageText: pageText, pageNumber: pageNumber, imageUrl: "")
                        page.pageImage = pageImage
                        self.pages.append(page)
                        self.pages.sort {$0.pageNumber < $1.pageNumber}
//                        print(count, pageNumber, self.pages.count, self.pages[count-1].pageNumber)
//                        count += 1
                    }
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch let error as NSError {
                print(error)
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
}
