//
//  Apihelper.swift
//  WeatherDemo
//
//  Created by Oleg Ten on 10/5/22.
//

import Foundation
import Alamofire

protocol CityProtocol {
    func cityCurrentData(apiKind: ApiKind, forCity: String, complition: @escaping (CityData) -> ())
    func cityAstronomyData(apiKind: ApiKind, forCity: String, complition: @escaping (CityAstronomyData) -> ())
}

enum ApiKind: String {
    case current = "current"
    case forecast = "forecast"
    case astronomy = "astronomy"
    case history = "history"
    case search = "search"
}

class ApiHelper: CityProtocol {
    
    static var shared = ApiHelper()
    
    func cityCurrentData(apiKind: ApiKind, forCity: String, complition: @escaping (CityData) -> ()) {
        let url = "https://api.weatherapi.com/v1/\(apiKind).json?key=908091de44534cae97a35444221005&q=\(forCity)&aqi=yes"
        Alamofire.request(url).responseJSON { response in
            
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(CityData.self, from: response.data!) {
                
                let city = json
                complition(city)
            }
        }
    }
    
    func cityAstronomyData(apiKind: ApiKind, forCity: String, complition: @escaping (CityAstronomyData) -> ()) {
        let url = "https://api.weatherapi.com/v1/\(apiKind).json?key=908091de44534cae97a35444221005&q=\(forCity)&aqi=no"
        Alamofire.request(url).responseJSON { response in
            
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(CityAstronomyData.self, from: response.data!) {
                
                let cityAstronomy = json
                complition(cityAstronomy)
            }
        }
    }
    
    func cityForecastData(apiKind: ApiKind, forCity: String, complition: @escaping ([Forecastday]) -> ()) {
        let url = "https://api.weatherapi.com/v1/\(apiKind).json?key=908091de44534cae97a35444221005&q=\(forCity)&days=2&aqi=no"
        Alamofire.request(url).responseJSON { response in
            
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(CityForecastData.self, from: response.data!) {
                
                let cityForecast = json
                complition(cityForecast.forecast.forecastday)
            }
        }
    }
    
    func citySearchData(apiKind: ApiKind, forCity: String, complition: @escaping ([SearchCity]) -> ()) {
        let url = "https://api.weatherapi.com/v1/search.json?key=908091de44534cae97a35444221005&q=\(forCity)"
        Alamofire.request(url).responseJSON { response in
            
            let decoder = JSONDecoder()
            if let json = try? decoder.decode([SearchCity].self, from: response.data!) {
                
                let searchCities = json
                complition(searchCities)
            }
        }
    }
}

struct CityData: Codable {
    var location: Location,
        current: Current
}

struct CityAstronomyData: Codable {
    var location: Location,
        astronomy: Astronomy
}

struct CityForecastData: Codable {
    var location: Location,
        forecast: Forecast,
        current: Current
}

struct Location: Codable {
    var name: String,
        region: String,
        country: String,
        lat: Double,
        lon: Double,
        tz_id: String,
        localtime_epoch: Int,
        localtime: String
}

struct Current: Codable {
    var temp_c: Double,
        condition: Condition,
        air_quality: AQI
}

struct AQI: Codable {
    var co: Double
}

struct Astronomy: Codable {
    var astro: Astro
}

struct Astro: Codable {
    var sunrise: String
    var sunset: String
}

struct Forecast: Codable {
    var forecastday: [Forecastday]
}

struct Forecastday: Codable {
    var hour: [Hour]
}

struct Hour: Codable {
    var time: String,
        temp_c: Double,
        condition: Condition
}

struct Condition: Codable {
    var text: String,
        icon: String
}

struct SearchCity: Codable {
    var name: String,
        country: String
}
