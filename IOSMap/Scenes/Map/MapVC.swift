//
//  MapVC.swift
//  IOSMap
//
//

import UIKit
import MapKit

class MapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var airplaneImage: UIImageView!
    var screenSize = UIScreen.main.bounds
    var cities = [ProvinceDataModel]()
    
    var my_marker = CustomPointAnnotation()
    var pinAnnotationView: MKPinAnnotationView!
    var type : MapSeeViewType? = .All
    var selectedCity : ProvinceDataModel?
    var viewDetail: CityCard!
    var announcementMarkers = [CustomPointAnnotation]()
    
    var openLat = 0.0
    var openLng = 0.0
    var openID = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapSeeSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mapSeeSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.reloadMap()
        mapView.selectedAnnotations.removeAll()
        
    }
    
    
}
//MARK: - View Setup
extension MapVC{
    public func mapSeeSetup(){
        self.cities = []
        self.mapSetup()
        self.createDetail()
        self.getCityList()
        self.reloadMap()
        
    }
    func getCityList(){
        
        if let localData = self.readLocalFile(forName: "cities_of_turkey") {
            self.parse(jsonData: localData)
        }
    }
}

// MARK: - Map Setup
extension MapVC: MKMapViewDelegate {
    func mapSetup(){
        self.mapView.mapType = MKMapType.hybrid
        self.mapView.delegate = self
        self.mapView.showsUserLocation = false // mavi lokasyon gösteren simgeyi kaldırma
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "map_marker")
        
        if let anno = annotation as? CustomPointAnnotation {
            annotationView.image = UIImage(named: anno.pinImageName)
            annotationView.isDraggable = anno.isDraggable
            annotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            annotationView.layer.shadowColor = UIColor.black.cgColor
            annotationView.layer.shadowOffset = CGSize.zero
            annotationView.layer.shadowRadius = 1
            annotationView.layer.shadowOpacity = 0.2
            
        }
        
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let anno = view.annotation as? CustomPointAnnotation {
            if anno.nickName == "announcementMarker" {
                view.image = UIImage(named: "red_loc_pin")
                
                setPlaceZoom(anno.coordinate)
            }
        }
        guard let annotation = view.annotation as? CustomPointAnnotation else { return }
        let id = annotation.tag ?? -1
        if id >= 0 {
            self.changePinImage(view: view, selected: true)
            selectedCity = cities[id]
            self.showDetailView(selectedCity: self.selectedCity!)
            self.showView(view: viewDetail!)
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.hideView(view: viewDetail!)
        self.changePinImage(view: view, selected : false)
        self.reloadMap()
    }
    func updateAnnouncementMarkers() {
        deleteAnnouncementMarkers()
        
        for i in 0..<cities.count {
            let lati = Double(cities[i].latitude ?? "0.0")
            let lat = lati ?? 0.0
            
            let long = Double(cities[i].longitude ?? "0.0")
            let lng = long ?? 0.0
            
            announcementMarkers.append(CustomPointAnnotation())
            if lat != 0 {
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                announcementMarkers[i].coordinate = location
                announcementMarkers[i].tag = i
                announcementMarkers[i].nickName = "announcementMarker"
                announcementMarkers[i].isDraggable = false
                announcementMarkers[i].pinImageName = "red_loc_pin"
                
                pinAnnotationView = MKPinAnnotationView(annotation: announcementMarkers[i], reuseIdentifier: "map_marker")
                mapView.addAnnotation(pinAnnotationView.annotation!)
            }
        }
        
        mapView.fit(annos: announcementMarkers)
        
    }
    func deleteAnnouncementMarkers() {
        if announcementMarkers.count != 0 {
            mapView.removeAnnotations(announcementMarkers)
        }
        announcementMarkers.removeAll()
    }
    
}
//MARK: - Sets
extension MapVC {
    
    public func setPlaceZoom(_ coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters:100000, longitudinalMeters: 100000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func reloadMap(){
        if cities.count > 0 {
            updateAnnouncementMarkers()
            if self.type == .Single {
                openMap(lat: openLat, lng: openLng, id: openID)
            }else{
                mapView.selectedAnnotations.removeAll()
            }
        }else{
            deleteAnnouncementMarkers()
            mapView.fit()
        }
    }
    func createDetail(){
        
        viewDetail = (Bundle.main.loadNibNamed("CityCard", owner: nil, options: nil)!.first as? CityCard)!
        viewDetail.frame = CGRect(x: 32, y: self.screenSize.height/4 - 32 , width:  self.screenSize.width - 64, height: viewDetail.cityView.frame.height)
        viewDetail.layer.masksToBounds = false
        viewDetail?.alpha = 0
        self.view.addSubview(viewDetail!)
    }
    func showView(view: UIView) {
        UIView.animate(withDuration: 0.8, delay: 0.5, options: [], animations: {
            self.airplaneImage.center.x += 200
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            view.alpha = 1
            view.frame = CGRect(x: 32, y: self.screenSize.height/4 - 32 , width: self.screenSize.width - 64, height: self.viewDetail.cityView.frame.height)
            
        }, completion: nil)
    }
    
    func hideView(view: UIView) {
        UIView.animate(withDuration: 0.8, delay: 0.5, options: [], animations: {
            self.airplaneImage.center.x -= 200
        }, completion: nil)
        
        UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            view.alpha = 0
            view.frame = CGRect(x: 32, y: self.screenSize.height/4 - 32 , width: self.screenSize.width - 64, height: self.viewDetail.cityView.frame.height)
            
        }, completion: nil)
    }
    
    func changePinImage(view: MKAnnotationView, selected : Bool){
        
        if selected{
            UIView.animate(withDuration: 0.5) {
                view.transform = .init(scaleX: 2.0, y: 2.0)
            }
        }
        else {
            UIView.animate(withDuration: 0.5) {
                view.transform = .init(scaleX: 1.0, y: 1.0)
            }
        }
        
    }
    
    public func openMap(lat: Double, lng: Double, id: Int){
        let selectID = id
        let index = self.cities.firstIndex(where: {$0.id == selectID}) ?? -1
        let stringIndex = String(index)
        
        for annotation in mapView.annotations {
            if let anno = annotation as? CustomPointAnnotation {
                if anno.tag == index {
                    mapView.selectedAnnotations.append(anno)
                    break
                }
            }
        }
        
    }
    
    func showDetailView(selectedCity : ProvinceDataModel){
        
        viewDetail?.configView(city: selectedCity)
        viewDetail?.alpha = 1.0
        
        
    }
    
    
}
// MARK: - JSON Read - Parse
extension MapVC {
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(DataModel.self,
                                                       
                                                       from: jsonData)
            
            self.cities.append(contentsOf: decodedData.data ?? [])
            self.reloadMap()
        } catch {
            print("decode error")
        }
    }
    
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
}
