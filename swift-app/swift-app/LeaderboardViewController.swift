//
//  LeaderboardViewController.swift
//  swift-app
//
//  Created by Jamie Lo on 21/02/2026.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let cellIdentifier = "cellIdentifier"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.dataModel.getAllScores().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        let scores = appDelegate.dataModel.getAllScores()
        cell.imageView?.image = scores[indexPath.row].getSelfie()
        cell.textLabel?.text = scores[indexPath.row].getName()
        cell.detailTextLabel?.text = "\(scores[indexPath.row].getScore())"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
