//
//  File.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/13/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import CoreData

class Page {
    
    let storyId: String
    let pageText: String
    let pageNumber: Int
    let imageUrl: String
    var pageImage: UIImage?
    
    init(storyId:String, pageText: String, pageNumber: Int, imageUrl: String) {
        self.storyId = storyId
        self.pageText = pageText
        self.pageNumber = pageNumber
        self.imageUrl = imageUrl
    }
    
    init(dictionary: [String:Any]) {
        self.storyId = dictionary[C_STORYID] as! String
        self.pageText = dictionary[C_PAGETEXT] as! String
        self.pageNumber = dictionary[C_PAGENUMBER] as! Int
        self.imageUrl = dictionary[C_IMAGEURL] as! String
    }
    
    func savePageToCoreData(handler: @escaping (_ error: Error?) -> Void) {
        if !pageExistsInCoreData() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            let entity = NSEntityDescription.entity(forEntityName: C_PAGES, in: managedContext)!
            let request = NSManagedObject(entity: entity, insertInto: managedContext)
            request.setValue(self.storyId, forKey: C_STORYID)
            request.setValue(self.pageNumber, forKey: C_PAGENUMBER)
            request.setValue(self.pageText, forKey: C_PAGETEXT)
            request.setValue(self.imageUrl, forKey: C_IMAGEURL)
            loadImage(from: self.imageUrl) { (imageData) in
                request.setValue(imageData, forKey: C_PAGEIMAGE)
                do {
                    try managedContext.save()
                    handler(nil)
                    print(self.pageNumber, " saved to Core Data")
                } catch let error as NSError {
                    handler(error)
                }
            }
        }
        else {
            print(self.pageNumber, " already in Core Data")
            handler(nil)
        }
    }
    
    func pageExistsInCoreData() -> Bool {
        var exists = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_PAGES)
        let storyIdPredicate = NSPredicate(format: "storyId = %@", self.storyId)
        let pageNumberPredicate = NSPredicate(format: "pageNumber = %i", self.pageNumber)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [storyIdPredicate, pageNumberPredicate])
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
