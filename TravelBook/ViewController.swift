//
//  ViewController.swift
//  TravelBook
//
//  Created by Semih Kalaycı on 13.08.2021.
//

import UIKit
import MapKit //haritaları kullanabilmek için
import  CoreLocation // konum işlemleri için
import CoreData

class ViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate { // delegate edebilmek için ekle
    
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var commentTextView: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var choosenLat = Double()
    var choosenLong = Double()
    var locationManager = CLLocationManager()
    var selectedTitle = ""
    var selectedTitleId : UUID?
    var annotationTitle = ""
    var annotationSubTitle = ""
    var annotationLat = Double()
    var annotationLong = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // konumu ne kkadar doğrulukla bulsun
        locationManager.requestWhenInUseAuthorization() // sadece uygulama çalışırken kullan
        locationManager.startUpdatingLocation() // kullanıcının yerini almaya başlıyoruz
        
        
 
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:))) // basılı tutma işlemi için tanımlama
        
        gestureRecognizer.minimumPressDuration = 2 // basılı tutma süresini ayarlar
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != "" {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let idString = selectedTitleId!.uuidString
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString )
            fetchRequest.returnsDistinctResults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title
                            if let subTitle = result.value(forKey: "subTitle") as? String{
                                annotationSubTitle = subTitle
                                if let lat = result.value(forKey: "latitude") as? Double{
                                    annotationLat = lat
                                    if let long = result.value(forKey: "longitude") as? Double{
                                        annotationLong = long
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubTitle
                                        let coordinate =  CLLocationCoordinate2D(latitude: annotationLat, longitude: annotationLong)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameTextView.text = annotationTitle
                                        commentTextView.text = annotationSubTitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate , span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                    
                                }
                                
                            }
                        }
              
              
                      
                        
                    }
                }else{
                    
                }
                
                
            } catch  {
                print("Error View did load")
            }
            
        }else{
            
        }
    }
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began{ //dokunma başladı mı
            let touchPoint = gestureRecognizer.location(in: self.mapView) // mapview üzerinde dokunulan noktayı al
            let touchedCordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView) // çevir
            
            choosenLat = touchedCordinates.latitude
            choosenLong = touchedCordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCordinates
            annotation.title = nameTextView.text
            annotation.subtitle = commentTextView.text
            self.mapView.addAnnotation(annotation)
            
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { // didUpdateLocation olarak arat
        
        if selectedTitle == "" {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) // kordinat atandı
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // oluşan konuma zoomlamak için kullanılır
        let region = MKCoordinateRegion(center: location, span: span) // konum ve zoom ayarlarını birleştir
        mapView.setRegion(region, animated: true) // mapta göster
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reusedID="myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedID) as? MKPinAnnotationView
        
        
        if pinView == nil { // pinview oluşturuyoruz
            
            pinView=MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedID)
            pinView?.canShowCallout = true // bir baloncukla ek bilgi gösterilebilen yer
            pinView?.tintColor = UIColor.black // navigasyona gidecek button rengi
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else{
            pinView?.annotation = annotation
        }
        
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
                
            let requestLocation = CLLocation(latitude: annotationLat, longitude: annotationLong)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in // bu yapının adı closure
                
                if let placemark = placemarks{
                    if placemark.count > 0   {
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0]) // map item oluşturabilmek için gerekiyor buda reversGeolocatindan alıyoruz
                        let item = MKMapItem(placemark: newPlacemark) //navigasyonu açmak için oluşturuyoruz
                        item.name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving] // hangi modda açıcaz
                        item.openInMaps(launchOptions: launchOptions)
                        
                        
                        
                    }
                    
                }
                    
             
            }
            
            
            
        }else{
            
        }
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameTextView.text, forKey: "title")
        newPlace.setValue(commentTextView.text, forKey: "subTitle")
        newPlace.setValue(choosenLat, forKey: "latitude")
        newPlace.setValue(choosenLong, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            
            try  context.save()
            print("saved")
            
        }catch{
            print("error saved")
            
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
       
    }
    
}

