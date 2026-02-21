//
//  DataModel.swift
//  swift-app
//
//  Created by Jamie Lo on 21/02/2026.
//
import UIKit

class DataModel {
    var allScores = [Score]()
    
    init() {
        //dummy data
        allScores.append(Score(date: "12/02/2026", time: "12:00", selfie: UIImage(named: "mario")!, name: "Jamie Lo", score: 100))
    }
    
    open func getAllScores() -> [Score] {
        return allScores
    }
}

class Score {
    private var date: String
    private var time: String
    private var selfie: UIImage
    private var name: String
    private var score: Int
    
    init(date:String, time:String, selfie:UIImage, name:String, score:Int) {
        self.date = date
        self.time = time
        self.selfie = selfie
        self.name = name
        self.score = score
    }
    public func getDate() -> String {
        return date
    }
    public func getTime() -> String {
        return time
    }
    public func getSelfie() -> UIImage {
        return selfie
    }
    public func getName() -> String {
        return name
    }
    public func getScore() -> Int {
        return score
    }
}
