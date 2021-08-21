//
//  ViewController.swift
//  UICollectionViewPagingExample
//
//  Created by 長内幸太郎 on 2021/08/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SampleCollectionViewCell", for: indexPath) as! SampleCollectionViewCell
        cell.label.text = "\(indexPath.item)"
        return cell
    }
    
}


class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return cellHorizontalCenterTargetContentOffset(proposedContentOffset: proposedContentOffset, velocity: velocity)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        itemSize = CGSize(width: 280.0, height: 150.0)
        sectionInset = .zero
        minimumLineSpacing = 30
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("🐵 ", collectionView.calcCurrentPage())
    }
}

extension UICollectionView {
    
    /// item番目のcellのcenter x
    func centerX(item: Int) -> CGFloat {
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }
        if item == 0 {
            return layout.itemSize.width / 2.0
        }
        return CGFloat(item) * (layout.itemSize.width + layout.minimumLineSpacing) + layout.itemSize.width / 2.0
    }
    
    func calcCurrentPage() -> Int {
        let currentCenter: CGFloat = contentOffset.x + bounds.width / 2.0
        var i = 1
        var currentPage: Int = 0
        while (true) {
            let x = centerX(item: i)
            if x > currentCenter {
                let leftCenterX = centerX(item: i - 1)
                let rightCenterX = centerX(item: i)
                let leftDistanceX = abs(leftCenterX - currentCenter)
                let rightDistanceX = abs(rightCenterX - currentCenter)
                if leftDistanceX < rightDistanceX {
                    currentPage = i - 1
                }
                else {
                    currentPage = i
                }
                break
            }
            else {
                i += 1
            }
        }
        
        return currentPage
    }
}

extension UICollectionViewFlowLayout {

    // MARK: - Horizontal

    /// item番目のcellのcenter x
    func centerX(item: Int) -> CGFloat {
        if item == 0 {
            return itemSize.width / 2.0
        }
        return CGFloat(item) * (itemSize.width + minimumLineSpacing) + itemSize.width / 2.0
    }
    
    func leftX(item: Int) -> CGFloat {
        return CGFloat(item) * itemSize.width + CGFloat(max(item - 1, 0)) * minimumLineSpacing
    }
    
    /// センターに合わせる
    func cellHorizontalCenterTargetContentOffset(proposedContentOffset: CGPoint, velocity: CGPoint) -> CGPoint {

        guard let collectionView = collectionView else {
            return proposedContentOffset
        }

        // 左端である
        let isLeft = proposedContentOffset.x < 0
        
        // 右端である
        let remainScroll = collectionView.contentSize.width - collectionView.bounds.width - collectionView.contentOffset.x
        let maxX = collectionView.contentSize.width - collectionView.bounds.width + collectionView.contentInset.right
        let isRight = (remainScroll <= 0)
        
        // 指を離したタイミングでのページ番号
        let currentCenter: CGFloat = collectionView.contentOffset.x + collectionView.bounds.width / 2.0
        var i = 1
        var currentPage: Int = 0
        while (true) {
            let x = centerX(item: i)
            if x > currentCenter {
                let leftCenterX = centerX(item: i - 1)
                let rightCenterX = centerX(item: i)
                let leftDistanceX = abs(leftCenterX - currentCenter)
                let rightDistanceX = abs(rightCenterX - currentCenter)
                if leftDistanceX < rightDistanceX {
                    currentPage = i - 1
                }
                else {
                    currentPage = i
                }
                break
            }
            else {
                i += 1
            }
        }
        
        let lastPage = collectionView.numberOfItems(inSection: 0) - 1
        
        // 右方向　左端ではない
        if velocity.x > 0.2 && !isRight {
            // velocity.x が閾値より大きい場合 (アイテムを左右にフリックした場合)
            let nextPage = currentPage + 1
            
            if nextPage == lastPage {
                // 右端
                return CGPoint(x: maxX, y: proposedContentOffset.y)
            }
            
            return CGPoint(x: centerX(item: nextPage) - collectionView.bounds.width / 2.0 , y: proposedContentOffset.y)
        }
        
        // 左方向　右端ではない
        if velocity.x < -0.2 && !isLeft {
            // velocity.x が閾値より大きい場合 (アイテムを左右にフリックした場合)
            let nextPage = currentPage - 1
            
            if nextPage == 0 {
                // 左端
                return CGPoint(x: -collectionView.contentInset.left , y: proposedContentOffset.y)
            }
            
            return CGPoint(x: centerX(item: nextPage) - collectionView.bounds.width / 2.0 , y: proposedContentOffset.y)
        }
        
        // 左端
        if isLeft {
            return CGPoint(x: -collectionView.contentInset.left , y: proposedContentOffset.y)
        }
        // 右端
        if isRight {
            return CGPoint(x: maxX, y: proposedContentOffset.y)
        }
        // それ以外
        return CGPoint(x: centerX(item: currentPage) - collectionView.bounds.width / 2.0 , y: proposedContentOffset.y)
        
    }

}
