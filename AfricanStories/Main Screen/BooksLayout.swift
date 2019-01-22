//
//  BooksLayout.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/12/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class BooksLayout: UICollectionViewFlowLayout {
    
    var PageWidth: CGFloat!
    var PageHeight: CGFloat!

    override func prepare() {
        super.prepare()
        
        scrollDirection = UICollectionView.ScrollDirection.horizontal
        itemSize = CGSize(width: PageWidth, height: PageHeight)
        minimumInteritemSpacing = 10
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: (collectionView?.bounds.width)! / 2 - PageWidth / 2, bottom: 0, right: (collectionView?.bounds.width)! / 2 - PageWidth / 2)
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let array = super.layoutAttributesForElements(in: rect) else {return nil}
        for attributes in array {
            let frame = attributes.frame
            let distance = abs((collectionView?.contentOffset.x)! + (collectionView?.contentInset.left)! - frame.origin.x)
            let scale = 1 * min(max(1 - distance / ((collectionView?.bounds.width)!), 0.75), 1)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }        
        return array
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var newOffset = CGPoint()
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        let width = layout.itemSize.width + layout.minimumLineSpacing
        var offset = proposedContentOffset.x + collectionView!.contentInset.left

        if velocity.x > 0 {
            offset = width * ceil(offset / width)
        } else if velocity.x == 0 { //6
            offset = width * round(offset / width)
        } else if velocity.x < 0 { //7
            offset = width * floor(offset / width)
        }
        newOffset.x = offset - collectionView!.contentInset.left
        newOffset.y = proposedContentOffset.y
        return newOffset
    }


    
    

}
