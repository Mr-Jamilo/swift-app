//
//  DataModel.swift
//  swift-app
//
//  Created by Jamie Lo on 21/02/2026.
//
import UIKit

class DataModel {
    let fileName = "leaderboard"
    var filePath: URL!
    var allScores = [Score]()
    
    init() {
        let tempDocDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let tempFileURL = tempDocDirURL.appendingPathComponent(fileName).appendingPathExtension("json")
        self.filePath = tempFileURL
        
        //dummy data
//        allScores.append(Score(id: 1, date: "12/02/2026", time: "12:00", selfie_name: "mario", name: "Jamie Lo", score: 100))
    }
    open func writeToFile() {
        
    }
    
    open func readFromFile() {
        guard FileManager.default.fileExists(atPath: filePath.path) else { return }
        
        do {
            let data = try Data(contentsOf: filePath)
            allScores = try JSONDecoder().decode([Score].self, from: data)
            print("Successfully loaded \(allScores.count) scores.")
        } catch {
            print("Read failed: \(error)")
        }
    }
    
    open func getFilePath() -> String {return filePath.path}
    
    open func getAllScores() -> [Score] {
        readFromFile()
        return allScores
    }
}

class Score: Codable {
    private var id: Int
    private var date: String
    private var time: String
    private var selfie_name: String
    private var name: String
    private var score: Int
    
    init(id:Int, date:String, time:String, selfie_name:String, name:String, score:Int) {
        self.id = id
        self.date = date
        self.time = time
        self.selfie_name = selfie_name
        self.name = name
        self.score = score
    }
    public func getId() -> Int {return id}
    public func getDate() -> String {return date}
    public func getTime() -> String {return time}
    public func getSelfieName() -> String {return selfie_name}
    public func getName() -> String {return name}
    public func getScore() -> Int {return score}
}
