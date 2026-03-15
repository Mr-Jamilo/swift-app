//
//  DataModel.swift
//  swift-app
//
//  Created by Jamie Lo on 21/02/2026.
//
import UIKit

class DataModel {
    private let bundleFileURL = Bundle.main.url(forResource: "leaderboard", withExtension: "json")

    // URL to a writable copy in the app's Documents directory
    private lazy var documentsFileURL: URL? = {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return docs.appendingPathComponent("leaderboard.json")
    }()

    private(set) var allScores: [Score] = []

    init() {
        // Load from Documents first if present; otherwise fall back to bundle resource
        readFromFile()
    }

    // Writes current scores to a writable file in Documents. Note: you cannot write to the app bundle.
    open func writeToFile() {
        guard let targetURL = documentsFileURL else { return }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            let data = try encoder.encode(allScores)
            try data.write(to: targetURL, options: [.atomic])
        } catch {
            print("[DataModel] Failed to write scores: \(error)")
        }
    }

    // Reads scores from Documents if available; otherwise falls back to the bundled JSON.
    open func readFromFile() {
        let fm = FileManager.default
        var sourceURL: URL? = nil

        if let docsURL = documentsFileURL, fm.fileExists(atPath: docsURL.path) {
            sourceURL = docsURL
        } else {
            sourceURL = bundleFileURL
        }

        guard let url = sourceURL else {
            print("[DataModel] No leaderboard.json found in bundle or documents.")
            allScores = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let scores = try decoder.decode([Score].self, from: data)
            self.allScores = scores
        } catch {
            print("[DataModel] Failed to read/parse scores: \(error)")
            self.allScores = []
        }
    }

    // Returns the resolved file path used for reading (Documents if exists, otherwise bundle)
    open func getFilePath() -> String? {
        let fm = FileManager.default
        if let docsURL = documentsFileURL, fm.fileExists(atPath: docsURL.path) {
            return docsURL.path
        }
        return bundleFileURL?.path
    }

    open func getAllScores() -> [Score] {
        // Ensure we return latest from storage
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
    public func getId() -> Int {return id}
    public func getDate() -> String {return date}
    public func getTime() -> String {return time}
    public func getSelfieName() -> String {return selfie_name}
    public func getName() -> String {return name}
    public func getScore() -> Int {return score}
}
