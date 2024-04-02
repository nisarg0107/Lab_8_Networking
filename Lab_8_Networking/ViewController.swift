//
//  ViewController.swift
//  Lab_8_Networking
//
//  Created by user238292 on 4/1/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var city: UILabel!
   
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var windspeed: UILabel!
    
    
    let GPS = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GPS.delegate = self
        GPS.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            GPS.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getDataFromAPI(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] result in
                switch result {
                case .success(let success):
                    DispatchQueue.main.async {
                        self?.updateUI(data: success)
                    }
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func updateUI(data: WeatherData) {
        city.text = data.name ?? ""
        descLabel.text = data.weather?.first?.description ?? ""
        if let weatherurl = URL(string: "https://openweathermap.org/img/wn/\(data.weather?.first?.icon ?? "")@2x.png") {
            imgview.load(url: weatherurl)
        }
        humidity.text = "Humidity: \(data.main?.humidity ?? 0)"
        windspeed.text = "Wind: \(data.wind?.speed ?? 0)Km/h"
        temperature.text = "\(Int(data.main?.temp ?? 0))°C"
    }
    
    func getDataFromAPI(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> ()) {
        guard let urlLink = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=9915fab4290e8740ec4bf5a74c2e2d28&units=metric") else { return }
        URLSession.shared.dataTask(with: URLRequest(url: urlLink)) { jsonData, _, error in
            guard let jsonData = jsonData else { return }
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}



extension UIImageView {
 func load(url: URL) {
     DispatchQueue.global().async { [weak self] in
         if let details = try? Data(contentsOf: url) {
             if let image = UIImage(data: details) {
                 DispatchQueue.main.async {
                     self?.image = image
                 }
             }
         }
     }
 }
}

