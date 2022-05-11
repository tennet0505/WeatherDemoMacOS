//
//  AppDelegate.swift
//  WeatherDemo
//
//  Created by Oleg Ten on 10/5/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusBarIcon = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarIcon.button?.title = "🌦"
        statusBarIcon.button?.target = self
        statusBarIcon.button?.action = #selector(showWeather)
        
        if UserDefaultsHelper.favCities == nil {
        let cities: [String] = ["London", "Bishkek", "Amsterdam"]
            UserDefaultsHelper.favCities = cities
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


    @objc func showWeather() {
        let sb = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError()
        }
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .applicationDefined
        popoverView.show(relativeTo: self.statusBarIcon.button!.bounds, of: self.statusBarIcon.button!, preferredEdge: .maxY)
    }
}

