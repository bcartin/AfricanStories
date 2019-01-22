//
//  PreviewController.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/26/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class PreviewController: UIViewController {
    
    let backgroundImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "background22"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let image1: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    let image2: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    let image3: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.6)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let previewText: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont()
        label.numberOfLines = 0
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .lightGray
        
        view.addSubview(backgroundImage)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        let height: CGFloat
        
        switch deviceType {
        case .iPad:
            height = view.frame.height * 0.4
        case .iPhone:
            height = view.frame.height * 0.6
        }
        let width = height/0.75
        
        var rotation = CGAffineTransform(rotationAngle: 100 / 300)
        let scale = 0.85
        var scaledAndRotated = rotation.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
 
        view.addSubview(image2)
        image2.setSizeAnchors(height: height, width: width)
        image2.centerVertically(in: view, offset: -height/4)
        image2.centerHorizontaly(in: view, offset: height)
        image2.transform = scaledAndRotated
        
        rotation = CGAffineTransform(rotationAngle: -100 / 300)
        scaledAndRotated = rotation.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
        view.addSubview(image3)
        image3.setSizeAnchors(height: height, width: width)
        image3.centerVertically(in: view, offset: -height/4)
        image3.centerHorizontaly(in: view, offset: -height)
        image3.transform = scaledAndRotated
        
        view.addSubview(image1)
        image1.setSizeAnchors(height: height, width: width)
        image1.centerVertically(in: view, offset: -height/4)
        image1.centerHorizontaly(in: view, offset: 0)
        
        view.addSubview(textContainerView)
        textContainerView.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: 20, paddingRight: 50)
        
        textContainerView.addSubview(previewText)
        previewText.anchor(top: textContainerView.topAnchor, left: textContainerView.leftAnchor, bottom: textContainerView.bottomAnchor, right: textContainerView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10)
        
        view.addSubview(homeButton)
        homeButton.setSizeAnchors(height: 40, width: 40)
        homeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 30)
    }
    
    @objc fileprivate func homeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
