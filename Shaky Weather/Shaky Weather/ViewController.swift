//
//  ViewController.swift
//  Shaky Weather
//
//  Created by Kyle Haptonstall on 1/19/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    // MARK: - Class Variables
    var currentLat:CLLocationDegrees?
    var currentLon:CLLocationDegrees?
    let locationManager = CLLocationManager()
    
    
    // MARK: - Storyboard Outlets
    @IBOutlet weak var shakeImage: UIImageView!
    @IBOutlet weak var weatherIconImage: UIImageView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        self.view.bringSubviewToFront(shakeImage)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Class Methods
    
    /**
        Uses the user current latitude and longitude to access the forcast.io api and gather current
        weather data.
    
        - parameter lat: User's current latitude
        - parameter lon: User's current longitude

        - returns: completion handler, wSummary, wTemp, wIcon
    */
    func loadWeather(atLatitude lat: CLLocationDegrees, andLongitude lon: CLLocationDegrees, withCompletion completion: ((wSummary:String, wTemp:Double, wIcon:String) -> Void)){
        
        let url = NSURL(string: "https://api.forecast.io/forecast/1d647ff195097d776374cf5199531057/\(lat),\(lon)")

        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            let json = JSON(data: data!)
            if let current = json["currently"].dictionary{
                let summary = current["summary"]!.stringValue
                let icon = current["icon"]!.stringValue
                let temp = current["temperature"]!.doubleValue
                completion(wSummary: summary, wTemp: temp, wIcon: icon)
            }
        }
        task.resume()
    }
    
    /**
     
     Sets the icon, temp, and weather summary after the user has shaked the phone.
     
     - parameter summary: Summary of the current weather
     - parameter temp: Current weather temp
     - parameter icon: Weather icon provided by API
     */
    func updateViewWithWeather(summary: String, temp: Double, icon: String){

        var iconImg = UIImage()
        var bgImg = UIImage()
        switch icon{
        case "clear-day":
            iconImg = UIImage(named: "Sun")!
            bgImg = UIImage(named: "SunStock")!
        case "clear-night":
            iconImg = UIImage(named: "Moon")!
            bgImg = UIImage(named: "MoonStock")!
        case "rain":
            iconImg = UIImage(named: "Rain")!
            bgImg = UIImage(named: "RainStock")!
        case "snow", "sleet":
            iconImg = UIImage(named: "Snow")!
            bgImg = UIImage(named: "SnowStock")!
        case "wind", "fog", "cloudy", "partly-cloudy-day", "partly-cloudy-night":
            iconImg = UIImage(named: "Cloudy")!
            bgImg = UIImage(named: "CloudyStock")!
        default:
            iconImg = UIImage(named: "Sun")!
            bgImg = UIImage(named: "SunStock")!
        }
        
        self.view.bringSubviewToFront(self.weatherIconImage)
        self.weatherIconImage.image = iconImg
        self.backgroundImage.image = bgImg
        self.summaryLabel.text = summary
        self.tempLabel.text = "\(temp)F"
    }

    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if let latitude = currentLat, longitude = currentLon{
            loadWeather(atLatitude: latitude, andLongitude: longitude) { wSummary, wTemp, wIcon in
                dispatch_async(dispatch_get_main_queue()){
                    self.shakeImage.alpha = 0
                    self.updateViewWithWeather(wSummary, temp: wTemp, icon: wIcon)
                }
               
            }
        }
        
    }

    // MARK: - Location Manager Delegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        currentLat = location?.coordinate.latitude
        currentLon = location?.coordinate.longitude
    }
}

