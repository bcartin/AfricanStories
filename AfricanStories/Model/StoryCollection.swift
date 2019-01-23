//
//  StoryCollection.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/12/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class StoryCollection {
    
    var collection = [Story]()
    var booksSet = [String]()
    
    
    init() {}
    
    
    func loadStoriesFromWeb(handler: @escaping (_ error: Error?) -> Void) {
        Database.database().reference().child(C_STORIES).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            allObjects.forEach({ (snapshot) in
                guard let storyDictionary = snapshot.value as? [String:Any] else {return}
                let story = Story(storyDictionary: storyDictionary)
                story.saveStoryToCoreData(handler: { (error) in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    if story.isPurchased {
                        story.loadPagesFromWeb(handler: { (error) in
                            if let err = error {
                                print(err.localizedDescription)
                                return
                            }
                            self.collection.append(story)
                            if self.collection.count == allObjects.count {
                                handler(nil)
                            }
                        })
                    }
                    else {
                        self.collection.append(story)
                        if self.collection.count == allObjects.count {
                            handler(nil)
                        }
                    }
                })
            })
        }) { (error) in
            handler(error)
        }
    }
    
    func loadStoriesFromCoreData(handler: @escaping (_ error: Error?) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_STORIES)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    guard let storyId = result.value(forKey: C_STORYID) as? String else {return}
                    guard let title = result.value(forKey: C_TITLE) as? String else {return}
                    guard let isPurchased = result.value(forKey: C_ISPURCHASED) as? Bool else {return}
                    guard let summary = result.value(forKey: C_SUMMARY) as? String else {return}
                    guard let totalPages = result.value(forKey: C_TOTALPAGES) as? Int else {return}
                    guard let ageGroup1 = result.value(forKey: C_AGEGROUP1) as? Bool else {return}
                    guard let ageGroup2 = result.value(forKey: C_AGEGROUP2) as? Bool else {return}
                    guard let ageGroup3 = result.value(forKey: C_AGEGROUP3) as? Bool else {return}
                    guard let country = result.value(forKey: C_COUNTRY) as? String else {return}
                    guard let tribe = result.value(forKey: C_TRIBE) as? String else {return}
                    guard let author = result.value(forKey: C_AUTHOR) as? String else {return}
                    guard let editor = result.value(forKey: C_EDITOR) as? String else {return}
                    guard let illustrator = result.value(forKey: C_ILLUSTRATOR) as? String else {return}
                    guard let creativeDirector = result.value(forKey: C_CREATIVEDIRECTOR) as? String else {return}
                    guard let song = result.value(forKey: C_SONG) as? String else {return}
                    guard let coverImageUrl = result.value(forKey: C_COVERIMAGEURL) as? String else {return}
                    guard let demoImage1Url = result.value(forKey: C_DEMOIMAGE1URL) as? String else {return}
                    guard let demoImage2Url = result.value(forKey: C_DEMOIMAGE2URL) as? String else {return}
                    guard let demoImage3Url = result.value(forKey: C_DEMOIMAGE3URL) as? String else {return}
                    guard let contentString = result.value(forKey: C_CONTENT) as? String else {return}
                    let storyDict = [
                        C_STORYID: storyId,
                        C_TITLE: title,
                        C_ISPURCHASED: isPurchased,
                        C_SUMMARY: summary,
                        C_TOTALPAGES: totalPages,
                        C_AGEGROUP1: ageGroup1,
                        C_AGEGROUP2: ageGroup2,
                        C_AGEGROUP3: ageGroup3,
                        C_COUNTRY: country,
                        C_TRIBE: tribe,
                        C_AUTHOR: author,
                        C_EDITOR: editor,
                        C_ILLUSTRATOR: illustrator,
                        C_CREATIVEDIRECTOR: creativeDirector,
                        C_SONG: song,
                        C_COVERIMAGEURL: coverImageUrl,
                        C_DEMOIMAGE1URL: demoImage1Url,
                        C_DEMOIMAGE2URL: demoImage2Url,
                        C_DEMOIMAGE3URL: demoImage3Url,
                        C_CONTENT: contentString.components(separatedBy: ",")
                        ] as [String : Any]
                    let story = Story(storyDictionary: storyDict)
                    guard let imageData = result.value(forKey: C_COVERIMAGE) as? Data else {return}
                    story.coverImage = UIImage(data: imageData)
                    if isPurchased {
                        DispatchQueue.main.async {
                            story.loadPagesFromCoreData()
                        }
                    }
                    else {
                        guard let demoImage1 = result.value(forKey: C_DEMOIMAGE1) as? Data else {return}
                        story.demoImage1 = UIImage(data: demoImage1)
                        guard let demoImage2 = result.value(forKey: C_DEMOIMAGE2) as? Data else {return}
                        story.demoImage2 = UIImage(data: demoImage2)
                        guard let demoImage3 = result.value(forKey: C_DEMOIMAGE3) as? Data else {return}
                        story.demoImage3 = UIImage(data: demoImage3)
                    }
                    self.collection.append(story)
                    self.collection.sort { $0.isPurchased && !$1.isPurchased }
                    booksSet.append(storyId)
                }
            }
            handler(nil)
        } catch let error as NSError {
            handler(error)
        }
        
    }
}
