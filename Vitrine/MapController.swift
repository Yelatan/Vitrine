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
                if pins.count > 1 {
                    let src = CLLocation(latitude: pins[0].coordinates[1], longitude: pins[0].coordinates[0])
                    addOverlayToMapView(src, dest: location)
                    
                }
//
                bounds = bounds.includingCoordinate(location.coordinate)
                mapView.animate(with: .fit(bounds))
                locationManager.stopUpdatingLocation()
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
//        API.request( <#Method#>, url: url, params: params.get() as [String : AnyObject]) { response in
        //function to show on the map
        Alamofire.request(url, parameters: params.get()).responseJSON { response in
//            print(response)
            switch response.result {
                case .success(_):
                    //didn't fix
                    print("map controller")
                    let JSON = response.result.value as! Dictionary<String, AnyObject>
                
                    let routes : NSArray = JSON["routes"] as! NSArray
//                    print(routes)
                
                let polyline = routes.value(forKey: "overview_polyline") as! NSArray
                
                
                    if let points = (polyline.value(forKey: "points") as? NSArray){
                        self.addPolyLineWithEncodedStringInMap(points[0] as! String)
                    }
                
                    
                
                
//                    let routes = JSON["routes"] as? NSMutableArray
//                    print(routes)
//                    let polyline = routes?[0] as? NSDictionary
//                    print(polyline)
//                    let polyline2 = polyline?["overview_polyline"] as? NSMutableDictionary
//                    print(polyline2)
//                    if let points = polyline2?["points"] {
//                        self.addPolyLineWithEncodedStringInMap("knnfGeuetMq@fA_BjB_D~Eu@xAsAlCYn@qArBsC~Dg@x@aAvA_D|DmCzCqDtEuBtBSe@m@gAMc@G]?c@LyADmAJoK@eLH{BCmBMIS@a@hAIJ{@~@{@r@_D`BaAr@cDnBcCrAeEdC_IpEq@^mCuLuEwSm@oCaJqb@eEwRUm@UUk@?kEVu@Hm@JaU~F}DdA]EM?IAIKMYAgE?mFCi@?oGEkBAo@Ea@Gi@@}@AcE@oGHuDHsFDoEK}DC_@S{ASsAS{@i@_BOg@{@sAqEiHcBuB{AyBgAcB_@u@oBcEyI_ToBcFa@aBKkAMcDQeHGeAOaAYoAe@}AyB_EuEgHyBcCkAg@}@SwAIsFAmBI_AKw@Wo@g@o@w@k@s@mAkB]c@qI_NeZod@oCmEaDsGgDkGmHcMcB}CoEgHEOmDiGwByDuMkTsCcFgB_DO{@Ua@c@q@CW?SBS^m@tH{KTWLGf@IRQLa@?UASKSIIMGM?UHIHIPAJOVSt@wCpEcEdGgBjC{DpFgBbCm@j@UJs@b@u@VaBVuD\\sBRo@DgIjA}IxAs@TGFwAV_Ch@qCx@wAl@oAn@aBdAe@R}Bp@g@N[BeP|@iJf@mALeFXmBJWoIUkJlCS" as! String)
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
    
//    func drawMap ()
//    {
//        
//        let str = String(format:"https://maps.googleapis.com/maps/api/directions/json?origin=\(originLatitude),\(originlongitude)&destination=\(destinationlatitude),\(destinationlongitude)&key=AIzaSyC8HZTqt2wsl14eI_cKxxxxxxxxxxxx")
//        
//        
//        Alamofire.request(str).responseJSON { (responseObject) -> Void in
//            
//            let resJson = JSON(responseObject.result.value!)
//            print(resJson)
//            
//            if(resJson["status"].rawString()! == "ZERO_RESULTS")
//            {
//                
//            }
//            else if(resJson["status"].rawString()! == "NOT_FOUND")
//            {
//                
//            }
//            else{
//                
//                let routes : NSArray = resJson["routes"].rawValue as! NSArray
//                print(routes)
//                
//                let position = CLLocationCoordinate2D(latitude: self.sellerlatitude, longitude: self.sellerlongitude)
//                
//                let marker = GMSMarker(position: position)
//                marker.icon = UIImage(named: "mapCurrent")
//                marker.title = "Customer have selected same location as yours"
//                marker.map = self.Gmap
//                
//                let position2 = CLLocationCoordinate2D(latitude: self.Buyyerlatitude, longitude: self.Buyyerlongitude)
//                
//                let marker1 = GMSMarker(position: position2)
//                marker1.icon = UIImage(named: "makeupmarker")
//                marker1.title = self.locationAddress
//                marker1.map = self.Gmap
//                
//                let pathv : NSArray = routes.value(forKey: "overview_polyline") as! NSArray
//                print(pathv)
//                let paths : NSArray = pathv.value(forKey: "points") as! NSArray
//                print(paths)
//                let newPath = GMSPath.init(fromEncodedPath: paths[0] as! String)
//                
//                
//                let polyLine = GMSPolyline(path: newPath)
//                polyLine.strokeWidth = 3
//                polyLine.strokeColor = UIColor.blue
//                polyLine.map = self.Gmap
//                
//                let bounds = GMSCoordinateBounds(coordinate: position, coordinate: position2)
//                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
//                self.Gmap!.moveCamera(update)
//                
//            }
//        }
}
