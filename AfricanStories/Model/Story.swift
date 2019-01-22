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

class Story {
    
    let storyId: String
    let title: String
    let isPurchased: Bool
    let summary: String
    let totalPages: Int
    let tribe: String
    let country: String
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
    
    var pages = [Page]()
    
    init(storyDictionary: [String:Any]) {
        self.storyId = storyDictionary[C_STORYID] as! String
        self.title = storyDictionary[C_TITLE] as! String
        self.isPurchased = storyDictionary[C_ISPURCHASED] as! Bool
        self.summary = storyDictionary[C_SUMMARY] as! String
        self.totalPages = storyDictionary[C_TOTALPAGES] as! Int
        self.tribe = storyDictionary[C_TRIBE] as? String ?? ""
        self.country = storyDictionary[C_COUNTRY] as? String ?? ""
        self.ageGroup1 = storyDictionary[C_AGEGROUP1] as! Bool
        self.ageGroup2 = storyDictionary[C_AGEGROUP2] as! Bool
        self.ageGroup3 = storyDictionary[C_AGEGROUP3] as! Bool
        self.author = storyDictionary[C_AUTHOR] as! String
        self.editor = storyDictionary[C_EDITOR] as! String
        self.illustrator = storyDictionary[C_ILLUSTRATOR] as! String
        self.creativeDirector = storyDictionary[C_CREATIVEDIRECTOR] as! String
        self.song = storyDictionary[C_SONG] as! String
        self.coverImageUrl = storyDictionary[C_COVERIMAGEURL] as! String
        self.demoImage1Url = storyDictionary[C_DEMOIMAGE1URL] as! String
        self.demoImage2Url = storyDictionary[C_DEMOIMAGE2URL] as! String
        self.demoImage3Url = storyDictionary[C_DEMOIMAGE3URL] as! String
    }
    
    func loadPagesFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_PAGES)
        request.predicate = NSPredicate(format: "storyId = %@", self.storyId)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                var count = 1
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
                    print(count, pageNumber, self.pages.count, self.pages[count-1].pageNumber)
                    count += 1
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func loadPagesFromWeb(handler: @escaping (_ error: Error?) -> Void) {
        Database.database().reference().child(C_PAGES).child(self.storyId).observe(.value, with: { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            let storyId = snapshot.key
            allObjects.forEach({ (snapshot) in
                guard var pagesDictionary = snapshot.value as? [String:Any] else {return}
                pagesDictionary[C_STORYID] = storyId
                let page = Page(dictionary: pagesDictionary)
                page.savePageToCoreData(handler: { (error) in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    self.pages.append(page)
                    if self.pages.count == allObjects.count {
                        handler(nil)
                    }
                })
            })
        }) { (error) in
            handler(error)
        }
    }
    
    func saveStoryToCoreData(handler: @escaping (_ error: Error?) -> Void) {
        if !storyExistsInCoreData() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            let entity = NSEntityDescription.entity(forEntityName: C_STORIES, in: managedContext)!
            let request = NSManagedObject(entity: entity, insertInto: managedContext)
            request.setValue(self.storyId, forKey: C_STORYID)
            request.setValue(self.title, forKey: C_TITLE)
            request.setValue(self.isPurchased, forKey: C_ISPURCHASED)
            request.setValue(self.summary, forKey: C_SUMMARY)
            request.setValue(self.totalPages, forKey: C_TOTALPAGES)
            request.setValue(self.country, forKey: C_COUNTRY)
            request.setValue(self.tribe, forKey: C_TRIBE)
            request.setValue(self.ageGroup1, forKey: C_AGEGROUP1)
            request.setValue(self.ageGroup2, forKey: C_AGEGROUP2)
            request.setValue(self.ageGroup3, forKey: C_AGEGROUP3)
            request.setValue(self.author, forKey: C_AUTHOR)
            request.setValue(self.editor, forKey: C_EDITOR)
            request.setValue(self.illustrator, forKey: C_ILLUSTRATOR)
            request.setValue(self.creativeDirector, forKey: C_CREATIVEDIRECTOR)
            request.setValue(self.song, forKey: C_SONG)
            request.setValue(self.coverImageUrl, forKey: C_COVERIMAGEURL)
            request.setValue(self.demoImage1Url, forKey: C_DEMOIMAGE1URL)
            request.setValue(self.demoImage2Url, forKey: C_DEMOIMAGE2URL)
            request.setValue(self.demoImage3Url, forKey: C_DEMOIMAGE3URL)
            loadImage(from: self.coverImageUrl) { (imageData) in
                request.setValue(imageData, forKey: C_COVERIMAGE)
                self.loadImage(from: self.demoImage1Url, handler: { (demoImage1) in
                    request.setValue(demoImage1, forKey: C_DEMOIMAGE1)
                    self.loadImage(from: self.demoImage2Url, handler: { (demoImage2) in
                        request.setValue(demoImage2, forKey: C_DEMOIMAGE2)
                        self.loadImage(from: self.demoImage3Url, handler: { (demoImage3) in
                            request.setValue(demoImage3, forKey: C_DEMOIMAGE3)
                            do {
                                try managedContext.save()
                                handler(nil)
                                print(self.title, " saved to Core Data")
                            } catch let error as NSError {
                                handler(error)
                            }
                        })
                    })
                })
            }
            
        }
        else {
            print(self.title, " already In Core Data")
            handler(nil)
        }
    }
    
    func updateIsPurchasedStatus(to status: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_STORIES)
        request.predicate = NSPredicate(format: "storyId = %@", self.storyId)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    result.setValue(status, forKey: C_ISPURCHASED)
                    do{
                        try managedContext.save()
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func storyExistsInCoreData() -> Bool {
        var exists = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_STORIES)
        request.predicate = NSPredicate(format: "storyId = %@", self.storyId)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                exists = true
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return exists
    }
    
    func savePagesToCoreData() {
        
    }
    
    func loadImage(from url: String, handler: @escaping (_ imageData: Data) -> ()) {
        guard let url = URL(string: url) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let imageData = data else {return}
            DispatchQueue.main.async {
                handler(imageData)
            }
            }.resume()
    }
    
}
