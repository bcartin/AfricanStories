//
//  GlossaryItem.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 1/8/19.
//  Copyright © 2019 garsontech. All rights reserved.
//

import UIKit
import CoreData


class GlossaryItem {
    
    let word: String
    let meaning: String
    
    init(word: String, meaning: String) {
        self.word = word
        self.meaning = meaning
    }
    
    init(dictionary: [String:Any]) {
        self.word = dictionary[C_WORD] as! String
        self.meaning = dictionary[C_MEANING] as! String
    }
    
    func saveItemToCoreData() {
        if !itemExistsInCoreData() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            let entity = NSEntityDescription.entity(forEntityName: C_GLOSSARY, in: managedContext)!
            let request = NSManagedObject(entity: entity, insertInto: managedContext)
            request.setValue(self.word, forKey: C_WORD)
            request.setValue(self.meaning, forKey: C_MEANING)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func itemExistsInCoreData() -> Bool {
        var exists = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_GLOSSARY)
        request.predicate = NSPredicate(format: "word = %@", self.word)
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
    
}
