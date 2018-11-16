//
//  Highscore.swift
//  Anagrams
//
//  Created by Flavia on 14.11.18.
//  Copyright © 2018 Flavia. All rights reserved.
//

import Foundation

class Highscore: NSObject, NSCoding {
	
	// MARK: Data
	
	let word: String
	private(set) var score: Int
	private(set) var player: String
	
	private(set) var guessedWords = [String: [String]]()
	
	// MARK: Initialiser
	
	init(word: String, score: Int, player: String) {
		self.word = word
		self.score = score
		self.player = player
	}
	
	
	// MARK: Saving
	
	required init?(coder aDecoder: NSCoder) {
		self.word = aDecoder.decodeObject(forKey: "word") as! String
		self.score = aDecoder.decodeInteger(forKey: "score")
		self.player = aDecoder.decodeObject(forKey: "player") as! String
		self.guessedWords = aDecoder.decodeObject(forKey: "guessedWords") as? [String: [String]] ?? [String: [String]]()
		// TODO: Save guessedWords correctly
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(word, forKey: "word")
		aCoder.encode(score, forKey: "score")
		aCoder.encode(player, forKey: "player")
		aCoder.encode(guessedWords, forKey: "guessedWords")
	}
	
	func addGuessedWord(player: String, word: String) {
		if guessedWords.keys.contains(player) {
			var alreadyGuessedWords = guessedWords[player]!
			alreadyGuessedWords.append(word)
			guessedWords[player] = alreadyGuessedWords
		} else {
			guessedWords[player] = [word]
		}
	}
	
	func addGuessedWords(player: String, words: [String]) {
		for word in words {
			addGuessedWord(player: player, word: word)
		}
	}
	
	func getAllGuessedWordsFor(player: String) -> [String]? {
		return guessedWords[player]
	}
	
	func updateHighscore(player: String, score: Int) {
		if self.score >= score {
			print("ERROR: Highscore added would have been lower. New: score: \(score), player: \(player). Old: \(self)")
			return
		}
		self.player = player
		self.score = score
	}
	
	// MARK: Helper functions
	
	override public var description: String {
		return "word: \(word); score: \(score); player: \(player)"
	}
	
}
