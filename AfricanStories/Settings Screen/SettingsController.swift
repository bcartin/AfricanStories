//
//  SettingsController.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/28/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    let backgroundImage = UIImageView(image: #imageLiteral(resourceName: "background22"))
    
    let filter = ["All Stories", "Age(s) 4-6", "Age(s) 7-12", "Age(s) 13 and above"]
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFontLarge()
        label.text = "SETTINGS"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "home").withRenderingMode(.alwaysOriginal), for: .normal)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Restore Purchases", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.defaultFont()
//        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return button
    }()
    
    let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About this App"
        label.textColor = .white
        label.font = UIFont.defaultFont()
        return label
    }()
    
    let iconCreditsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont()
        let attributedText = NSMutableAttributedString(string: "Icons: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedText.append(NSMutableAttributedString(string: "Dave Gandy, Google, Freepik", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black]))
        label.attributedText = attributedText
        return label
    }()
    
    let musicCreditsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont()
        let attributedText = NSMutableAttributedString(string: "Music: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedText.append(NSMutableAttributedString(string: "bensound.com", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black]))
        label.attributedText = attributedText
        return label
    }()
    
    let developmentCreditsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont()
        let attributedText = NSMutableAttributedString(string: "Development: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedText.append(NSMutableAttributedString(string: "garsontech.com", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black]))
        label.attributedText = attributedText
        return label
    }()
    
    let copyRightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont()
        let attributedText = NSMutableAttributedString(string: "Copyright: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedText.append(NSMutableAttributedString(string: "FamilyRubies", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black]))
        label.attributedText = attributedText
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        
        view.addSubview(backgroundImage)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(homeButton)
        homeButton.setSizeAnchors(height: 40, width: 40)
        homeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 30)
        
        view.addSubview(titleLabel)
        titleLabel.centerHorizontaly(in: view, offset: 0)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(restoreButton)
        restoreButton.centerHorizontaly(in: view, offset: 0)
        restoreButton.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(aboutLabel)
        aboutLabel.centerHorizontaly(in: view, offset: 0)
        aboutLabel.anchor(top: restoreButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(iconCreditsLabel)
        iconCreditsLabel.centerHorizontaly(in: view, offset: 0)
        iconCreditsLabel.anchor(top: aboutLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(musicCreditsLabel)
        musicCreditsLabel.centerHorizontaly(in: view, offset: 0)
        musicCreditsLabel.anchor(top: iconCreditsLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(developmentCreditsLabel)
        developmentCreditsLabel.centerHorizontaly(in: view, offset: 0)
        developmentCreditsLabel.anchor(top: musicCreditsLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(copyRightLabel)
        copyRightLabel.centerHorizontaly(in: view, offset: 0)
        copyRightLabel.anchor(top: developmentCreditsLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
    }
    

    
    @objc fileprivate func homeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filter.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filter[row]
    }
    
    
}
