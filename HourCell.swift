//
//  HourCell.swift
//  WeatherDemo
//
//  Created by Oleg Ten on 10/5/22.
//

import Cocoa

class HourCell: NSCollectionViewItem {

    @IBOutlet weak var hourLabel: NSTextField!
    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var tempLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
