//
//  ViewController.swift
//  TravelBook
//
//  Created by Semih Kalaycı on 13.08.2021.
//

import UIKit
import MapKit //haritaları kullanabilmek için
import  CoreLocation // konum işlemleri için

class ViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate { // delegate edebilmek için ekle
    
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var commentTextView: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
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
}

