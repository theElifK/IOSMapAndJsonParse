//
//  CityCard.swift
//  IOSMap
//
//  Created by Elif Karakolcu on 14.03.2023.
//

import UIKit

class CityCard: UIView {

    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var plaka: UILabel!
    @IBOutlet weak var il: UILabel!
    @IBOutlet weak var nufus: UILabel!
    @IBOutlet weak var bolge: UILabel!
    
    func configView(city: ProvinceDataModel){
       
        self.plaka.text = String(city.id ?? 0)
        self.il.text = String(city.name ?? "-")
        self.nufus.text = String(city.population ?? 0)
        self.bolge.text = String(city.region ?? "-")
        
       
    }

}
