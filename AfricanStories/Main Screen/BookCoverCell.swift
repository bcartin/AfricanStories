//
//  BookCoverCell.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/7/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

protocol BookCoverCellDelegate {
    func didTapBuyButton(storyId: String)
}

class BookCoverCell: UICollectionViewCell {
    
    var delegate: BookCoverCellDelegate?
    
    var isPurchased = false {
        didSet {
            addBuyButton()
            showBuyButton()
        }
    }
    
    var storyId: String?
    
    var price: NSDecimalNumber = 0 {
        didSet {
            let priceString = "$\(price)\n BUY"
            self.buyButton.setTitle(priceString, for: .normal)
        }
    }
    
    var frameColor: bookFrameColor! {
        didSet {
            backgroundImage.image = UIImage(named: frameColor.rawValue)
        }
    }
    
    let backgroundImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let bookCoverImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let coverView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        return view
    }()
    
    let buyImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "priceTag2"))
        return iv
    }()
    
    let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("BUY\n $1.99", for: .normal)
        button.titleLabel?.font = UIFont.defaultFont()
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let bookmarkImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "vertical-bookmark"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let pagesLabel: UILabel = {
        let label = UILabel()
        label.text = "21p"
        label.textAlignment = .center
        label.font = UIFont.defaultFontSmall()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundImage)
        backgroundImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        let height = self.frame.height * 0.83
        addSubview(coverView)
        coverView.setSizeAnchors(height: height, width: height / 0.75) //self.frame.width * 0.95)
        coverView.anchor(top: backgroundImage.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 20)
        coverView.centerHorizontaly(in: self, offset: 0)
        coverView.addSubview(bookCoverImage)
        bookCoverImage.anchor(top: coverView.topAnchor, left: coverView.leftAnchor, bottom: coverView.bottomAnchor, right: coverView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -5, paddingRight: 0)
        
        addSubview(bookmarkImage)
        bookmarkImage.setSizeAnchors(height: self.frame.height * 0.15, width: self.frame.height * 0.15)
        bookmarkImage.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 0)
        
        addSubview(pagesLabel)
        pagesLabel.centerHorizontaly(in: bookmarkImage, offset: 0)
        pagesLabel.anchor(top: bookmarkImage.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
//        addBuyButton()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBuyButton() {
        
        if !isPurchased {
        
        switch deviceType {
        case .iPad:
            buyImageView.setSizeAnchors(height: 150, width: 150)
        case .iPhone:
            buyImageView.setSizeAnchors(height: 75, width: 75)
        }
        
        addSubview(buyImageView)
        buyImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 0)
        
        buyButton.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        addSubview(buyButton)
        buyButton.centerHorizontaly(in: buyImageView, offset: 0)
        buyButton.centerVertically(in: buyImageView, offset: -10)
            
        }
    }
    
    func showBuyButton() {
        if isPurchased {
            buyButton.alpha = 0
            buyImageView.alpha = 0
        }
        else {
            buyButton.alpha = 1
            buyImageView.alpha = 1
        }
    }
    
    @objc func buyTapped() {
        guard let storyId = self.storyId else {return}
        delegate?.didTapBuyButton(storyId: storyId)
    }
    

    
    
}
