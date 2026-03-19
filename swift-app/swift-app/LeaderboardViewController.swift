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
        cell.detailTextLabel?.text = "\(scores[indexPath.row].getScore())"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
