//
//  ViewController.swift
//  WeatherGifts
//
//  Created by ilya Yudakov on 23.11.2020.
//

import UIKit

class LocationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var weatherLocations: [WeatherLocation] = []
    var selectedLocationIndex = 0
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var weatherLocation = WeatherLocation(name: "Moscow", latitude: 55.7522200, longitude: 37.6155600)
        weatherLocations.append(weatherLocation)
        weatherLocation = WeatherLocation(name: "Saint-Petersburg", latitude: 59.9386300, longitude: 30.3141300)
        weatherLocations.append(weatherLocation)
        weatherLocation = WeatherLocation(name: "Krasnodar", latitude: 45.0448400, longitude: 38.9760300)
        weatherLocations.append(weatherLocation)
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    func saveLocation() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations) {
            UserDefaults.standard.set(encoded, forKey: "weatherLocations")
        } else {
            print ("😡 ERROR: Saving encoded didn't work!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
        saveLocation()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
    }
}

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = weatherLocations[sourceIndexPath.row]
        weatherLocations.remove(at: sourceIndexPath.row)
        weatherLocations.insert(itemToMove, at: destinationIndexPath.row)
    }
}

