//
//  CellModalViewController.swift
//  swift-app
//
//  Created by Jamie Lo on 20/03/2026.
//
import UIKit

class CellModalViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    var userName: String?
    var userScore: String?
    var userSelfieImageName: String?
    var userDate: String?
    var userTime: String?
    let docDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if userSelfieImageName != "none" {
            let imageURL = docDirUrl.appendingPathComponent(userSelfieImageName!).appendingPathExtension("jpg")
            imageView.image = UIImage(contentsOfFile: imageURL.path)
        } else {
            imageView.image = UIImage(named:userSelfieImageName!)
        }
        
        nameLabel.text = userName
        scoreLabel.text = userScore
        dateLabel.text = userDate
        timeLabel.text = userTime
    }
}
