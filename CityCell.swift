//
//  CityCell.swift
//  WeatherDemo
//
//  Created by Oleg Ten on 10/5/22.
//

import Cocoa

protocol CityCellProtocol: AnyObject {
    func removeCell(atIndex: Int)
}

class CityCell: NSTableCellView {
    
    @IBOutlet weak var cityName: NSTextField!
    @IBOutlet weak var stateLabel: NSTextField!
    @IBOutlet weak var degreeLabel: NSTextField!
    var indexCity = 0
    weak var cityCellDelegate: CityCellProtocol?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        layer?.backgroundColor = CGColor(red: 0/255, green: 140/255, blue: 198/255, alpha: 1)
        layer?.cornerRadius = 8
    }
    @IBAction func closeButton(_ sender: Any) {
        cityCellDelegate?.removeCell(atIndex: indexCity)
    }
    
}
