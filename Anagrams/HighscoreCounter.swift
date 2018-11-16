//
//  HighscoreCounter.swift
//  Anagrams
//
//  Created by Flavia on 14.11.18.
//  Copyright © 2018 Flavia. All rights reserved.
//

import Foundation

class HighscoreCounter: NSObject, NSCoding {
	
	private var highscores = [Highscore]()
	
	override init() {
		super.init()
		//only for testing
	}
	
	// MARK: NSCoding
	
	required init?(coder aDecoder: NSCoder) {
		highscores = aDecoder.decodeObject(forKey: "highscores") as? [Highscore] ?? [Highscore]()
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(highscores, forKey: "highscores")
	}
	
	// MARK: public fuctions
	
	func getNumberOfHighscores() -> Int {
		return highscores.count
		// TODO: check that played Words and saved Highscores are the same length
	}
	
	/**
	Returns all the words where highscores have already been achieved
	*/
	func getAllHighscoreWords() -> [String] {
		var highscoreWords = [String]()
		for hs in highscores {
			highscoreWords.append(hs.word)
		}
		return highscoreWords
	}
	
	func getHighscore(at index: Int) -> Highscore? {
		if highscores.count <= index {
			return nil
		}
		return highscores[index]
	}
	
	func getHighscoreFor(word: String) -> Highscore? {
		for hs in highscores {
			if hs.word == word {
				return hs
			}
		}
		return nil
	}
	
	/**
	Adds the highscore to the list of highscore or updates the existing one if there is already a highscore for that word.
	TODO: Try to link to comment of other function instead of duplicating it.
	*/
	func addHighscore(word: String, score: Int, player: String) {
		if let oldHighscore = getHighscoreFor(word: word) {
			oldHighscore.updateHighscore(player: player, score: score)
			//TODO: sort the updated highscore.
		} else {
			highscores.append(Highscore(word: word, score: score, player: player))
			//TODO: add at correct place according to sort order (by word or by score)
		}
	}
	
	/**
	Removes the highscore from the list of highscores.
	
	- Parameter word: The word you want to delete from the highscore list.
	- Returns: `true` if the word was in the highscore list and successfully deleted, `false` otherwise.
	*/
	func removeHighscore(for word: String) -> Highscore? {
		if let index = getIndexOfHighscoreFor(word: word) {
			let hs = highscores[index]
			removeHighscore(at: index)
			return hs
		}
		return nil
	}
	
	func removeHighscore(at index: Int) {
		highscores.remove(at: index)
	}
	
	func addGuessedWord(player: String, highscoreWord: String, guessedWord: String) {
		if let hs = getHighscoreFor(word: highscoreWord) {
			hs.addGuessedWord(player: player, word: guessedWord)
		} else {
			print("ERROR: addGuessedWordFor - Highscore word doesn't exist!")
		}
	}
	
	func addGuessedWords(player: String, highscoreWord: String, guessedWords: [String]) {
		for word in guessedWords {
			addGuessedWord(player: player, highscoreWord: highscoreWord, guessedWord: word)
			// TODO: could be more efficient if getHighscoreFor in addGuessedWord would only have to be called once.
		}
	}
	
	func getAllGuessedWordsFor(player: String, highscoreWord: String) -> [String]? {
		return getHighscoreFor(word: highscoreWord)?.getAllGuessedWordsFor(player: player)
	}
	
	//MARK: private functions
	
	private func getIndexOfHighscoreFor(word: String) -> Int? {
		for (index, hs) in highscores.enumerated() {
			if hs.word == word {
				return index
			}
		}
		return nil
	}
	
	private func sortHighscoreForScore() {
		// TODO
	}
	
	private func sortHighscoreForWord() {
		// TODO
	}
}
