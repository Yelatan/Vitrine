//
//  MapController.swift
//  Vitrine
//
//  Created by Vitrine on 27.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire

protocol MapObject {
    var id: String { get set }
    var name: String { get set }
    var coordinates: [Double] { get set } // [longitude, latitude]
}

class MapController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!    
    
    let locationManager = CLLocationManager()
    var bounds = GMSCoordinateBounds()
    var pins = [MapObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for pin in pins {
            if pin.coordinates.count > 1 {
                let  position = CLLocationCoordinate2DMake(pin.coordinates[1], pin.coordinates[0])
                let marker = GMSMarker(position: position)
                marker.title = pin.name
                marker.map = mapView
                bounds = bounds.includingCoordinate((marker.position))
            }
        }
        
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //didn't fix coordinates is undefined
//                if pins.count == 1 {
//                    let src = CLLocation(latitude: pins[0].coordinates[1], longitude: pins[0].coordinates[0])
//                    addOverlayToMapView(src, dest: location)
//                }
//                
//                bounds = bounds.includingCoordinate(location.coordinate)
//                mapView.animate(with: .fit(bounds))
//                locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func addOverlayToMapView(_ srcLocation: CLLocation, dest destLocation: CLLocation){
        let params = VitrineParams()
        let url = "https://maps.googleapis.com/maps/api/directions/json"
        
        params.main("origin", value: "\(srcLocation.coordinate.latitude),\(srcLocation.coordinate.longitude)")
        params.main("destination", value: "\(destLocation.coordinate.latitude),\(destLocation.coordinate.longitude)")
        params.main("key", value: "AIzaSyCx733GK-sIQlw5FZ9u-IPLUCtec3lJZng")
        //
        
//        API.request( <#Method#>, url: url, params: params.get() as [String : AnyObject]) { response in
        //function to show on the map
        Alamofire.request(url, parameters: params.get()).responseJSON { response in
            switch response.result {
                case .success(_):
                    //didn't fix
                    print("map controller")
                    let JSON = response.result.value as! Dictionary<String, AnyObject>
                    let routes = JSON["routes"] as? NSMutableArray
                    print(JSON)
                    print(routes)
//                    let polyline = routes?[0]["overview_polyline"] as! NSMutableDictionary
//                    if let points = polyline["points"] {
//                        self.addPolyLineWithEncodedStringInMap(points as! String)
//                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
            }
        }
    }
    
    func addPolyLineWithEncodedStringInMap(_ encodedString: String) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 2
        polyLine.strokeColor = UIColor.red
        polyLine.map = mapView
    }
}
