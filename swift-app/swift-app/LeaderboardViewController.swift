//
//  LeaderboardViewController.swift
//  swift-app
//
//  Created by Jamie Lo on 21/02/2026.
//
import UIKit

/// View controller for displaying the leaderboard
class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "cellIdentifier"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// Gets the number of rows required for the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.dataModel.getAllScores().count
    }
    
    /// Configurations for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let docDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        let scores = appDelegate.dataModel.getAllScores()
        if scores[indexPath.row].getSelfieName() != "none" {
            let imageURL = docDirUrl.appendingPathComponent(scores[indexPath.row].getSelfieName()).appendingPathExtension("jpg")
            cell.imageView?.image = UIImage(contentsOfFile: imageURL.path)
        } else {
            cell.imageView?.image = UIImage(named:scores[indexPath.row].getSelfieName())
        }
        cell.textLabel?.text = scores[indexPath.row].getName()
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        cell.detailTextLabel?.text = "\(scores[indexPath.row].getScore())"
        return cell
    }
    
    /// Passes the selected leaderboard entry to the modal detail view before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let modal = segue.destination as? CellModalViewController
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            
            let scores = appDelegate.dataModel.getAllScores()
            let selectedItem = scores[indexPath.row]
            modal!.userName = selectedItem.getName()
            modal!.userScore = "\(selectedItem.getScore())"
            modal!.userDate = selectedItem.getDate()
            modal!.userSelfieImageName = selectedItem.getSelfieName()
            modal!.userTime = selectedItem.getTime()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
