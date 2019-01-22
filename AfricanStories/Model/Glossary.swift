//
//  Glossary.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 1/8/19.
//  Copyright © 2019 garsontech. All rights reserved.
//

import Foundation
import Firebase
import CoreData

class GlossaryList {
    
    var items = [GlossaryItem]()
    
    func loadWordsFromWeb() {
        Database.database().reference().child(C_GLOSSARY).observeSingleEvent(of: .value) { (snapshot) in
            guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else {return}
            allObject.forEach({ (snapshot) in
                let word = snapshot.key
                let meaning = snapshot.value as! String
//                guard let itemDictionary = snapshot.value as? [String:Any] else {return}
                let item = GlossaryItem(word: word, meaning: meaning)
                item.saveItemToCoreData()
            })
        }
    }
    
    func loadWordFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_GLOSSARY)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                results.forEach { (result) in
                    let object = result as! NSManagedObject
                    guard let word = object.value(forKey: C_WORD) as? String else {return}
                    guard let meaning = object.value(forKey: C_MEANING) as? String else {return}
                    let item = GlossaryItem(word: word, meaning: meaning)
                    self.items.append(item)
                    self.items.sort {$0.word < $1.word}
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
}
