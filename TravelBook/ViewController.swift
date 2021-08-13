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
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) // kordinat atandı
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // oluşan konuma zoomlamak için kullanılır
        let region = MKCoordinateRegion(center: location, span: span) // konum ve zoom ayarlarını birleştir
        mapView.setRegion(region, animated: true) // mapta göster
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
       
    }
    
}

