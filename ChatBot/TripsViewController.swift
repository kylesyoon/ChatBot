//
//  File.swift
//  Flights
//
//  Created by Kyle Yoon on 2/11/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import UIKit
import QPXExpressWrapper

enum TripSelectionStatus {
    case selectedNone
    case selectedDeparture
    case selectedReturn
}

internal class TripsViewController: UIViewController {    
    @IBOutlet var tableView: UITableView!
    
    var searchResults: SearchResults?
    var selectedTripOption: TripOption?
    var tripsDataSource: TripsDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Available Options"
        
        self.tableView.register(UINib(nibName: String(describing: TripCell.self), bundle: nil),
                                forCellReuseIdentifier: String(describing: TripCell.self))
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 134.0
        if let searchResults = self.searchResults {
            self.tripsDataSource = TripsDataSource(searchResults: searchResults)
            self.tableView.reloadData()
        }
    }
}

extension TripsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let tripsDataSource = self.tripsDataSource {
            return tripsDataSource.numberOfSections()
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tripsDataSource = self.tripsDataSource {
            return tripsDataSource.numberOfRowsForSection(section: section)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TripCell.self), for: indexPath) as? TripCell,
            let dataSource = self.tripsDataSource else {
            return UITableViewCell()
        }
        
        let tripCellData = dataSource.tripCellDataForIndexPath(indexPath: indexPath)
        cell.configure(with: tripCellData)
        
        return cell
    }
}
