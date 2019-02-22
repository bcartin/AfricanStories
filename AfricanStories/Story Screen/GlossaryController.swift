//
//  GlossaryController.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/14/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class GlossaryController: UIViewController {
    
    let glossary = GlossaryList()
    
    let glossaryTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFontLarge()
        label.text = "GLOSSARY"
        return label
    }()
    
    let glossaryTableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        tv.backgroundColor = UIColor.clear
        return tv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegates()
        glossary.loadWordFromCoreData()
        glossaryTableView.reloadData()
    }
    
    fileprivate func setupDelegates() {
        glossaryTableView.delegate = self
        glossaryTableView.dataSource = self
    }
    
    fileprivate func setupUI() {
//        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        view.backgroundColor = UIColor.white
        
        view.addSubview(glossaryTitle)
        glossaryTitle.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        glossaryTitle.centerHorizontaly(in: view, offset: 0)
        
        view.addSubview(glossaryTableView)
        glossaryTableView.anchor(top: glossaryTitle.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        
    }
    

}

extension GlossaryController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return glossary.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = glossaryTableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let attributedText = NSMutableAttributedString(string: glossary.items[indexPath.item].word + ": ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedText.append(NSMutableAttributedString(string: glossary.items[indexPath.item].meaning, attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.attributedText = attributedText
        
        return cell
    }
    
    
}
