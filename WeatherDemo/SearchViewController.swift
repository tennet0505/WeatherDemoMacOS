//
//  SearchViewController.swift
//  WeatherDemo
//
//  Created by Oleg Ten on 11/5/22.
//

import Cocoa
import SDWebImage

protocol SearchViewProtocol: AnyObject {
    func reloadDataTableView(favCity: String)
}

class SearchViewController: NSViewController {

    @IBOutlet weak var searchTextField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var cityNameLabel: NSTextField!
    @IBOutlet weak var degreeLabel: NSTextField!
    @IBOutlet weak var stateLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    var cities: [SearchCity] = []
    var currentSearchCity = ""
    
    weak var searchViewDelegate: SearchViewProtocol?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor(red: 0/255, green: 140/255, blue: 198/255, alpha: 0.88)
        self.elements(hide: false)
        searchTextField.sendsSearchStringImmediately = true
    }
    
    @IBAction func addButton(_ sender: Any) {
        if !currentSearchCity.isEmpty {
            let queuq = DispatchQueue.global()
            queuq.sync {
                UserDefaultsHelper.shared.add(city: currentSearchCity)
                searchViewDelegate?.reloadDataTableView(favCity: currentSearchCity)
            }
        }
        self.dismiss(sender)
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(sender)
    }
}

extension SearchViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "searchID")
        
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? SearchCell else { return nil }
        cellView.nameLabel.stringValue = cities[row].name + ", " + cities[row].country
        
        return cellView

    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let table = notification.object as? NSTableView else {
            return
        }
        let row = table.selectedRow
        elements(hide: false)
        ApiHelper.shared.cityCurrentData(apiKind: ApiKind.current, forCity: cities[row].name) { city in
            let url = URL(string: city.current.condition.icon.replacingOccurrences(of: "//", with: "https://"))!
            self.cityNameLabel.stringValue = city.location.name
            self.degreeLabel.stringValue = "\(city.current.temp_c) ℃"
            self.stateLabel.stringValue = "\(city.current.condition.text)"
            self.imageView.sd_setImage(with: url)
            self.currentSearchCity = city.location.name
        }
    }
    
    func elements(hide: Bool) {
        scrollView.isHidden = !hide
        stackView.isHidden = hide
        addButton.isHidden = hide
        cancelButton.isHidden = hide
    }
}

extension SearchViewController: NSSearchFieldDelegate, NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        ApiHelper.shared.citySearchData(apiKind: .search, forCity: searchTextField.stringValue) { cities in
            self.elements(hide: true)
            self.cities = cities
            self.tableView.reloadData()
            print("didStart", self.cities)
        }
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        self.elements(hide: true)
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.cities.removeAll()
        self.elements(hide: false)
        self.tableView.reloadData()
        print("didEnd")
    }
}

