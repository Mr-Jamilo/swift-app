//
//  DataModel.swift
//  swift-app
//
//  Created by Jamie Lo on 21/02/2026.
//

import UIKit

/// Model for reading and writing to file
class DataModel {
    let fileName = "leaderboard"
    let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var fileURL: URL
    var allScores: [Score] = []

    init() {
        fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("json")
        readFromFile()
    }

    /// Appends a score and saves the leaderboard to file
    /// - Parameters:
    ///   - name: Player display name
    ///   - score: Player score value
    ///   - selfieName: Optional image filename stored separately, or nil
    open func writeToFile(name: String, score: Int, selfieName: String?) {
        readFromFile()
        let nextID = (allScores.map { $0.id }.max() ?? 0) + 1
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: now)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: now)
        
        let newScore = Score(
            id: nextID,
            date: dateString,
            time: timeString,
            selfie_name: selfieName ?? "none",
            name: name,
            score: score
        )
        allScores.append(newScore)
        allScores.sort { $0.score > $1.score }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(allScores)
            try jsonData.write(to: fileURL, options: .atomic)
            print("Successfully saved to leaderboard at: \(fileURL.path)")
        } catch {
            print("Error saving leaderboard: \(error.localizedDescription)")
        }
    }

    /// Loads leaderboard from disk if present; leaves cache unchanged if decoding fails
    open func readFromFile() {
        if let existingData = try? Data(contentsOf: fileURL) {
            let decoder = JSONDecoder()
            if let savedScores = try? decoder.decode([Score].self, from: existingData) {
                allScores = savedScores
            }
        }
    }

    /// Returns the filesystem path to leaderboard.json (for debugging/diagnostics)
    open func getFilePath() -> String? { fileURL.path }

    /// Returns the latest leaderboard by reloading from disk first
    open func getAllScores() -> [Score] {
        readFromFile()
        return allScores
    }
}

/// Codable Score model for a single JSON leaderboard entry
class Score: Codable {
    var id: Int
    var date: String
    var time: String
    var selfie_name: String
    var name: String
    var score: Int

    // Explicit coding keys to preserve current JSON field names
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case time
        case selfie_name
        case name
        case score
    }

    init(id:Int, date:String, time:String, selfie_name:String, name:String, score:Int) {
        self.id = id
        self.date = date
        self.time = time
        self.selfie_name = selfie_name
        self.name = name
        self.score = score
    }
    // Getters
    public func getId() -> Int {return id}
    public func getDate() -> String {return date}
    public func getTime() -> String {return time}
    public func getSelfieName() -> String {return selfie_name}
    public func getName() -> String {return name}
    public func getScore() -> Int {return score}
}

