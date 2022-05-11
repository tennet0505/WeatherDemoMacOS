//
//  ViewController.swift
//  WeatherDemo
//
//  Created by Oleg Ten on 10/5/22.
//

import Cocoa
import Alamofire
import SDWebImage
import CoreLocation

class ViewController: NSViewController {

    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var cityName: NSTextField!
    @IBOutlet weak var iconCurrentState: NSImageView!
    @IBOutlet weak var cityCurrentTemp: NSTextField!
    @IBOutlet weak var sunriseTime: NSTextField!
    @IBOutlet weak var sunsetTime: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var tableView: NSTableView!
    
    let houreCellIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "houreCellIdentifier")
    var hoursTemp: [Hour] = []
    var cities: [String] = []
    var favCities: [CityData] = []
    let locationManager = CLLocationManager()
    var splitViewIsVisible = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
       
        if let cities = UserDefaultsHelper.favCities {
            self.cities = cities
            self.loadingFav(cities: self.cities)
        }
        splitView.dividerStyle = .thin
        splitView.setValue(NSColor.white, forKey: "dividerColor")
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor(red: 0/255, green: 140/255, blue: 198/255, alpha: 0.88)
        
        let nib = NSNib(nibNamed: "HourCell", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "houreCellIdentifier"))
        collectionView.enclosingScrollView?.horizontalScroller?.alphaValue = 0.0
        collectionView.enclosingScrollView?.borderType = .lineBorder
        collectionView.enclosingScrollView?.layer?.cornerRadius = 8

    }

    override var representedObject: Any? {
        didSet {

        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        changeLeftPanelVisibility()
    }
    
    @IBAction func addNewCityButton(_ sender: Any) {
        performSegue(withIdentifier: "addNewCitySegue", sender: self)
    }
    
    func changeLeftPanelVisibility() {
        splitViewIsVisible = !splitViewIsVisible
        let newPosition: CGFloat = !splitViewIsVisible ? 220 : 0
        animateSplitView(
               toPosition: newPosition,
               ofDividerAt: 0,
               to: splitViewIsVisible
           )
    }
    
    func animateSplitView(
        toPosition position: CGFloat,
        ofDividerAt dividerIndex: Int,
        to visible: Bool
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = 0.75
            splitView.setPosition(position, ofDividerAt: dividerIndex)
            splitView.layoutSubtreeIfNeeded()
        }
    }
    
    func loadData(forCity: String) {
        ApiHelper.shared.cityCurrentData(apiKind: ApiKind.current, forCity: forCity) { city in
            let url = URL(string: city.current.condition.icon.replacingOccurrences(of: "//", with: "https://"))!
            self.cityName.stringValue = city.location.name
            self.cityCurrentTemp.stringValue = "\(city.current.temp_c) ℃"
            self.iconCurrentState.sd_setImage(with: url)
        }
        
        ApiHelper.shared.cityAstronomyData(apiKind: ApiKind.astronomy, forCity: forCity) { city in
            self.sunriseTime.stringValue = city.astronomy.astro.sunrise
            self.sunsetTime.stringValue = "\(city.astronomy.astro.sunset)"
        }
        
        ApiHelper.shared.cityForecastData(apiKind: ApiKind.forecast, forCity: forCity) { forecastdays in
            
            self.hoursTemp = self.filtering(forecastdays: forecastdays)
            self.collectionView.reloadData()
        }
    }
    
    func loadingFav(cities: [String]) {
        for city in cities {
            ApiHelper.shared.cityCurrentData(apiKind: ApiKind.current, forCity: city) { city in
                self.favCities.append(city)
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addNewCitySegue",
           let vc = segue.destinationController as? SearchViewController {
            vc.searchViewDelegate = self
        }
    }
        
}

extension ViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return hoursTemp.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(withIdentifier: houreCellIdentifier, for: indexPath) as? HourCell
        else { return NSCollectionViewItem()
        }
        let hourData = hoursTemp[indexPath.item]
        item.hourLabel.stringValue = dateConvert(time: hourData.time)
        item.tempLabel.stringValue = "\(hourData.temp_c) ℃"
        
        let url = URL(string: hourData.condition.icon.replacingOccurrences(of: "//", with: "https://"))!
        item.image.sd_setImage(with: url)
           
        return item
    }
    
    func filtering(forecastdays: [Forecastday]) -> [Hour] {
        var filtered: [Hour] = []
        var allHours: [Hour] = []
        for day in forecastdays {
            allHours.append(contentsOf: day.hour)
        }
        filtered = allHours.filter{ $0.time >= nearestHour() }
        return filtered
    }
    
    func dateConvert(time: String) -> String {
        var timeFormatted = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let dateObj = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "HH:mm"
            timeFormatted = dateFormatter.string(from: dateObj)
        }
        return timeFormatted
    }
    
    func nearestHour() -> String {
        var timeFormatted = ""
        let dateFormatter = DateFormatter()
        let currentHour = Date(timeIntervalSinceReferenceDate:
                                (Date.timeIntervalSinceReferenceDate / 3600.0).rounded(.toNearestOrEven) * 3600.0)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            timeFormatted = dateFormatter.string(from: currentHour)
        
        return timeFormatted
    }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return favCities.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cityCell")
        
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? CityCell else { return nil }
        
        cellView.cityCellDelegate = self
        cellView.cityName.stringValue = favCities[row].location.name
        cellView.stateLabel.stringValue = favCities[row].current.condition.text
        cellView.degreeLabel.stringValue = "\(favCities[row].current.temp_c) ℃"
        cellView.indexCity = row
        return cellView

    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let table = notification.object as? NSTableView else {
            return
        }
        let row = table.selectedRow
        loadData(forCity: favCities[row].location.name)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            loadData(forCity: "London")
        case .denied:
            loadData(forCity: "London")
        case .authorized:
            print("status authorized")
            let location = locationManager.location
            if let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude {
                let cityCoordinate = "\(Double(round(10000 * latitude) / 10000)),\(Double(round(10000 * longitude) / 10000))"
                print(cityCoordinate)
                loadData(forCity: cityCoordinate )
            }
        case .notDetermined:
            loadData(forCity: "London")
        default:
            loadData(forCity: "London")
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print( "location manager failed with error \(error)" )
    }
}

extension ViewController: CityCellProtocol, SearchViewProtocol {
    
    func removeCell(atIndex: Int) {
        
        cities.remove(at: atIndex)
        favCities.remove(at: atIndex)
        let indexSet = IndexSet(integer:atIndex)
        tableView.removeRows(at: indexSet, withAnimation: .effectFade)
        UserDefaultsHelper.shared.remove(indexCity: atIndex)
        tableView.reloadData()
    }
    
    func reloadDataTableView() {
        if let cities = UserDefaultsHelper.favCities {
            self.cities.removeAll()
            self.favCities.removeAll()
            self.cities = cities
            self.loadingFav(cities: self.cities)
        }
    }
}
