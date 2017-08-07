//
//  HomeVC.swift
//  Gini
//
//  Created by Nazar on 14/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import UIKit
import SCLAlertView

class HomeView: UIViewController {
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet var gridLayout: GridLayout!
    @IBOutlet weak var refreshBtn: UIButton!
    
    var refreshControl:UIRefreshControl = UIRefreshControl()
    let cellTotalMargin:CGFloat = 20
    let reuseIdentifier = "HomeCollectionCell" // also enter this string as the cell identifier in the storyboard
    var dataArray: [ModelImage] = []
    var deletePosition:Int? // is used to delete data from dataArray. Need to save it because of AlertView
    var numberOfPictures = 10
    
    let useSquareCells = true
    let useSections = false
    let itemSpacing = 10 //space between items
    let divisionCount = 3 //how many items can be placed in each row
    let scrollDirection = UICollectionViewScrollDirection.vertical
    private var longPressGesture: UILongPressGestureRecognizer!
    
    /// Mark - variable for Interactor
    var mImageID:String=""
    
    
    /// MARK Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh() //Prevent crash because of REALM - not a good solution since we should just stay with the same images but remove those cell we removed inside FAVORITE window
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func setup()
    {
        //get data (we shouldn't communicate to interactive directly because of the viper pattern
        preGetDataForView() //fetch data from internet
        setupTabBarBtn()
        
        uiCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        uiCollectionView.contentOffset = CGPoint(x: -10, y: -10)
        
        gridLayout.delegate = self
        gridLayout.itemSpacing = CGFloat(itemSpacing)
        gridLayout.fixedDivisionCount = UInt(divisionCount)
        gridLayout.scrollDirection = scrollDirection
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(HomeView.handleLongGesture))
        longPressGesture.minimumPressDuration = 0.2
        uiCollectionView.addGestureRecognizer(longPressGesture)
        
        //refresh data
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        uiCollectionView!.addSubview(refreshControl)
    }
    
    func refresh()
    {
        preGetDataForView() //fetch data from internet
    }
    
    fileprivate func setupTabBarBtn()
    {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        button.setImage(UIImage(named: "icon_favorite_tabbar"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(HomeView.goToFavoriteController), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    
    /// MARK ACTIONS
    @IBAction func refreshDataAction(_ sender: Any) {
        refresh()
    }
    
    
    /// MARK General functions
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = uiCollectionView.indexPathForItem(at: gesture.location(in: uiCollectionView)) else {
                break
            }
            if selectedIndexPath.row == preGetDataLengt() {
                //can't move this special cell
                MyAlertView.showWarningAlertWithCancelOnly(message: "You can't move this cell.")
                uiCollectionView.cancelInteractiveMovement()
                return
            }
            uiCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed: uiCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended: uiCollectionView.endInteractiveMovement()
        default: uiCollectionView.cancelInteractiveMovement()
        }
    }
    
    
    //
    func updateDataArray(sIndex: Int, dIndex: Int) {
        let item = dataArray[sIndex]
        
        //delegate to Presenter
        preRemoveImage(at: sIndex)
        preInsertImage(withItem: item, at: dIndex)
    }
    
    
    //
    func goToFavoriteController()
    {
        let destination = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteView") as! FavoriteView
        self.navigationController?.pushViewController(destination, animated: true)
    }
}



extension HomeView: GridLayoutDelegate {
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        return scale(forItemAt: indexPath)
    }
    
    func itemFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return useSquareCells ? fixedDimension : 0.8 * fixedDimension
    }
    
    func headerFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return useSections ? 60 : 0
    }
    
    
    // MARK: - Private
    
    private func scale(forItemAt indexPath: IndexPath) -> UInt {
        if indexPath.row == 0
        {
            return 2 //First row must be bigger
        }
        return 1
    }
}

extension HomeView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many sections to make
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return preGetDataLengt()+1 // the extra cell is for add button
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! HomeCollectionCell
        cell.delegate = self
        
        //we need to check, if this is last cell than we should add button and hide the image.
        if preGetDataLengt()==indexPath.item
        {
            //This transformation is delegated to the cell
            cell.setLastCell()
        }
        else
        {
            //get data for current row
            let imgModel = dataArray[indexPath.row]
            
            //set a image.. let's delegate this job to the cell itself
            cell.setImage(mImage: imgModel, isFavorite: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        updateDataArray(sIndex: sourceIndexPath.row, dIndex: destinationIndexPath.row)
    }
}


extension HomeView: HomeCollectionCellDelegate {
    
    func insertCell() {
        //change
        preGetAdditionalDataForView()
    }
    
    func insertFavoriteCell(cell: HomeCollectionCell) {
        guard let indexPath = uiCollectionView.indexPath(for: cell) else { return }
        
        //extract Image Model before saving
        let mImage = dataArray[indexPath.row]
        preSaveModelToFavorite(mImage: mImage)
        
        MyAlertView.showInformationAlert(message: "The picture was added to your favorite list")
    }
}

///This extension is for communication channel between Presenter and View
extension HomeView
{
    
    func updateArrayWithReceivedData(newData:[ModelImage])
    {
        //Show refresh button ONLY if our data array is empty
        refreshBtn.isHidden = !newData.isEmpty
        if newData.isEmpty
        {
            MyAlertView.showWarningAlertWithCancelOnly(message: "No images were received. Please, check your internet connection")
        }
        
        dataArray = newData
        
        uiCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func appendData(newData:[ModelImage])
    {
        let currentPhotoNumber = dataArray.count-1
        var indexPaths = [IndexPath]()
        
        for index in currentPhotoNumber...(currentPhotoNumber+numberOfPictures-1)
        {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        
        dataArray = newData
        
        uiCollectionView.performBatchUpdates({ () -> Void in
            self.uiCollectionView.insertItems(at: indexPaths)
        }, completion:nil)
    }
}
