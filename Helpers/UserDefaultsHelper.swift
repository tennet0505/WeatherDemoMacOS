//
//  UserDefaultsHelper.swift
//  WeatherDemo
//
//  Created by Oleg Ten on 10/5/22.
//

import Foundation

class UserDefaultsHelper {
    
    static var shared = UserDefaultsHelper()
    
    open class var favCities: [String]?{
        get {
            return  UserDefaults.standard.object(forKey: "UserDefaultsHelper.cityData") as? [String]
        } set{
            if let newValue = newValue{
                UserDefaults.standard.set(newValue, forKey: "UserDefaultsHelper.cityData")
            } else {
                UserDefaults.standard.set(nil, forKey: "UserDefaultsHelper.cityData")
            }
        }
    }
    
    func add(city: String) {
        if let favCities = UserDefaultsHelper.favCities {
            var cities = favCities
            cities.append(city)
            UserDefaultsHelper.favCities = cities
        }
    }
    
    func remove(indexCity: Int) {
        if let favCities = UserDefaultsHelper.favCities {
            var cities = favCities
            cities.remove(at: indexCity)
            UserDefaultsHelper.favCities = cities
        }
    }
}
