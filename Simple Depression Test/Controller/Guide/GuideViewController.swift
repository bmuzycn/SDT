//
//  GuideViewController.swift
//  testNav
//
//  Created by Yu Zhang on 12/14/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//


import UIKit

//public let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
//public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
//public let ScreenBounds: CGRect = UIScreen.main.bounds

class GuideViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var imageNames = ["g1".localized, "g2".localized, "g3".localized]
    private let cellIdentifier = "GuideCell"
    private var isHiddenNextButton = true
    private var pageController = UIPageControl()
    

    
    fileprivate func setPageControllerLayout() {
        var margins = UILayoutGuide()
        if #available(iOS 11.0, *) {
            margins = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            margins = view.layoutMarginsGuide
        }
        
        
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        pageController.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -50).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()

        buildCollectionView()
        buildPageController()
        
        setPageControllerLayout()
    }

    

    // MARK: - Build UI
    private func buildCollectionView() {

        collectionView.register(GuideCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.isPagingEnabled = true
        
    }
    
    func buildPageController() {
        pageController.numberOfPages = imageNames.count
        pageController.currentPage = 0
        pageController.pageIndicatorTintColor = UIColor.gray
        pageController.currentPageIndicatorTintColor = .orange
        view.addSubview(pageController)
    }
    
    
}

extension GuideViewController{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GuideCell
        cell.newImage = UIImage(named: imageNames[indexPath.row])
        if indexPath.row != imageNames.count - 1 {
            cell.setNextButtonHidden(hidden: true)
        }

        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == view.frame.width * CGFloat(imageNames.count - 1) {
            let cell = collectionView.cellForItem(at: NSIndexPath(row: imageNames.count - 1, section: 0) as IndexPath) as! GuideCell
            cell.setNextButtonHidden(hidden: false)
            isHiddenNextButton = false
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let x = targetContentOffset.pointee.x
        
        pageController.currentPage = Int(x / view.frame.width)
        
    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout()
            
            if self.pageController.currentPage == 0 {
                self.collectionView.contentOffset = .zero
            } else {
                let indexPath = IndexPath(item: self.pageController.currentPage, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        
    })
}
}
