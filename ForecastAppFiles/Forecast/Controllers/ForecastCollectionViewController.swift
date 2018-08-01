//
//  ForecastCollectionViewController.swift
//  Forecast
//
//  Created by Bryan Dubay on 5/31/18.
//  Copyright © 2018 Bryan Dubay. All rights reserved.
//

import UIKit
import CoreData
import SwiftSky
import CoreLocation

private let reuseIdentifier = "DayForecast"

class ForecastCollectionViewController: UICollectionViewController  {
    //Animation Properties
    private var customInteractor : CustomInteractor?
    private var selectedFrame : CGRect?
    private var selectedForecast: Forecast?
    private func selectedIcon(forecast:Forecast)-> UIImage?{
        if let icon = forecast.icon { return UIImage.init(named: icon) } else { return nil }
    }
    //UI properties
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    var refreshControl = UIRefreshControl()
    //Data properties
    let forecastCoreData = ForecastCoreDataInteractor()
    var location: CLLocationCoordinate2D! {
        didSet{
            activitySpinner.hidesWhenStopped = true
            activitySpinner.stopAnimating()
            self.loadNetworkForecast(location: location)
        }
    }
    var fetchController: NSFetchedResultsController<Forecast>? {
        didSet {
            collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.startAnimating()
        self.navigationController?.delegate = self
        self.collectionView!.alwaysBounceVertical = true
        self.refreshControl.addTarget(self, action: #selector(ForecastCollectionViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(self.refreshControl)
    }
    // MARK: - Data Loading
    func loadNetworkForecast(location:CLLocationCoordinate2D){
        ApiClient.performForecastRequest(location:location,completion: { (result) in
            self.refreshControl.endRefreshing()
            switch result {
            case .success:
                self.loadPersistedForecast()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    func loadBeforeTodayForecast () {
        do {
            try forecastCoreData.fetchedOldResultsController.performFetch()
        }
        catch {
            print(error.localizedDescription)
        }
        self.fetchController = forecastCoreData.fetchedOldResultsController
    }
    
    func loadPersistedForecast(){
        do {
            try forecastCoreData.fetchedResultsController.performFetch()
        }
        catch {
            print(error.localizedDescription)
        }
        self.fetchController = forecastCoreData.fetchedResultsController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        refreshControl.beginRefreshing()
        loadNetworkForecast(location: LocationService.usersLocation)
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue: segue) {
        case .DayDetail:
            let dayDetail = segue.destination as! DayDetailViewController
            
            guard let indexPath = sender as? IndexPath , let forecast = fetchController?.fetchedObjects?[indexPath.row] else { return }
            
            dayDetail.forecast = forecast
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let forecastCDResults = fetchController?.fetchedObjects else {
            return 0 }
        return forecastCDResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DayForecastCollectionViewCell

        if let forecast = fetchController?.fetchedObjects?[indexPath.row]{
            let min = forecast.minTemp
            let max = forecast.maxTemp
            cell.tempLabel.temperatureLabel(low: min, high: max)
            cell.dateLabel.text = forecast.date?.toString(dateFormat: "MMM dd")
            if let icon = forecast.icon { cell.iconImageView.image = UIImage.init(named: icon) }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theAttributes:UICollectionViewLayoutAttributes! = collectionView.layoutAttributesForItem(at: indexPath)
        selectedFrame = collectionView.convert(theAttributes.frame, to: collectionView.superview)
        selectedForecast = fetchController?.fetchedObjects?[indexPath.row]
        let sender = indexPath as AnyObject
        performSegueWithIdentifier(segueIdentifier: .DayDetail, sender: sender )
    }
    
    
    @IBAction func switched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadPersistedForecast()
            self.collectionView?.addSubview(self.refreshControl)
        case 1:
            loadBeforeTodayForecast()
            self.refreshControl.removeFromSuperview()
        default: break
        }
    }
    
}
// MARK: Transition Animation
extension ForecastCollectionViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let ci = customInteractor else { return nil }
        return ci.transitionInProgress ? customInteractor : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let frame = self.selectedFrame else { return nil }
        guard let forecast = self.selectedForecast else { return nil }
        
        switch operation {
        case .push:
            self.customInteractor = CustomInteractor(attachTo: toVC)
            return CustomAnimator(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: true, originFrame: frame, image:   selectedIcon(forecast: forecast)!)
        default:
            return CustomAnimator(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: false, originFrame: frame, image:   selectedIcon(forecast: forecast)!)
        }
    }
}
// MARK: Segue Helper
extension ForecastCollectionViewController : SegueHandlerType{
    enum SegueIdentifier: String {
        case DayDetail
    }
}

