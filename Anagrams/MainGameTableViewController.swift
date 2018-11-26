//
//  MainGameTableViewController.swift
//  Anagrams
//
//  Created by Flavia on 14.11.18.
//  Copyright © 2018 Flavia. All rights reserved.
//

import UIKit

class MainGameTableViewController: UITableViewController {
	
	var wordSelectionTVC: WordSelectionTableViewController?
	var isNewWord: Bool!
	var oldHighscore: Highscore?
	var settings: Settings? {
		return wordSelectionTVC?.settings
	}
	var language = Language.getDefaultLanguage()
	
	/// Returns the new highscore if it is higher than the old, `nil` otherwise.
	var newHighscore: Int? {
		get {
			if oldHighscore == nil || answers.count <= oldHighscore!.score {
				return nil
			} else {
				return answers.count
			}
		}
	}
	
	var isSamePlayerAsOldHighscore: Bool {
		get {
			return oldHighscore?.player == settings?.playerName
		}
	}
	
	var answers = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if title == nil || title!.isEmpty {
			askForCustomWord()
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(askForNewWord))
		
		if let title = title {
			answers = wordSelectionTVC?.highscoreCounter?.getAllGuessedWordsFor(player: settings!.playerName, highscoreWord: title) ?? [String]()
		}
		
    }
	
	private func askForCustomWord() {
		let ac = UIAlertController(title: "Set your word", message: "It should be at least 5 letters long.", preferredStyle: .alert)
		ac.addTextField()
		ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] action in
			let textFieldText = ac.textFields![0].text
			if textFieldText == nil || textFieldText!.count < 5 {
				// TODO: say text needs to be at least 5 letters
				self.title = self.wordSelectionTVC!.getRandomWord()
			} else {
				self.title = textFieldText!
				self.getLanguage(word: textFieldText!)
			}
		})
		present(ac, animated: true)
	}
	
	private func getLanguage(word: String) {
		let checker = UITextChecker()
		let range = NSMakeRange(0, word.utf16.count)
		let languages = Language.allLanguages
		var languagesPossible = [Language]()
		for language in languages {
			if checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: language.shortWord).location == NSNotFound {
				languagesPossible.append(language)
			}
		}
		if languagesPossible.count == 1 {
			self.language = languagesPossible[0]
			let acLanguageDetected = UIAlertController(title: "You're playing in \(self.language.longWord)", message: nil, preferredStyle: .alert)
			acLanguageDetected.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(acLanguageDetected, animated: true)
		} else {
			var title: String
			var message: String
			var data: [Language]
			if languagesPossible.count == 0 {
				title = "Language not recognised"
				message = "This word doesn't exist in the languages supported by this app. Please choose your language to play in:"
				data = Language.allLanguages
			} else {
				title = "Choose a language"
				message = "This word exists in multiple languages. Please choose in which you would like to play in:"
				data = languagesPossible
			}
			let acLanguageChooser = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
			for (i, language) in data.enumerated() {
				acLanguageChooser.addAction(UIAlertAction(title: language.longWord, style: .default) { [unowned self, data] action in
					self.language = data[i]
				})
			}
			self.present(acLanguageChooser, animated: true)
		}
	}
	
	@objc private func askForNewWord() {
		let ac = UIAlertController(title: "Add new Word", message: nil, preferredStyle: .alert)
		ac.addTextField()
		ac.addAction(UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] action in
			let answer = ac.textFields![0].text ?? ""
			self.submit(answer: answer)
		})
		present(ac, animated: true)
	}
	
	private func submit(answer: String) {
		if answer.isEmpty {
			return
		}
		
		if isPossible(word: answer) {
			if isOriginal(word: answer) {
				if isReal(word: answer) {
					if isLongEnough(word: answer) {
						if isNotSameWord(word: answer) {
							addNewWord(word: answer)
							return
						} else {
							showErrorMessage(title: "Nice try", message: "But using the starter word is a bit uncreative don't you think?")
						}
					} else {
						showErrorMessage(title: "Word too short", message: "The word should be at least three letters long!")
					}
				} else {
					showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
				}
			} else {
				showErrorMessage(title: "Word used already", message: "Be more original!")
			}
		} else {
			showErrorMessage(title: "Word not possible", message: "You can't spell \(answer) from '\(title!.lowercased())'!")
		}
	}
	
	private func addNewWord(word: String) {
		answers.insert(word, at: 0)
		
		let indexPath = IndexPath(row: 0, section: 1)
		tableView.insertRows(at: [indexPath], with: .automatic)
		tableView.reloadRows(at: [IndexPath(row: answers.count - 1, section: 1)], with: .automatic)
		tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
		
		handleHighscore(forNewWord: word)
		wordSelectionTVC!.highscoreCounter!.addGuessedWord(player: settings!.playerName, highscoreWord: title!, guessedWord: word)
		wordSelectionTVC!.save()
		// TODO: tell about highscore if changed
	}
	
	private func handleHighscore(forNewWord: String) {
		let word = title!
		let score = answers.count
		let player = wordSelectionTVC!.getPlayerName()
		if isNewWord {
			wordSelectionTVC!.highscoreCounter!.addHighscore(word: word, score: score, player: player, language: language)
		} else {
			if newHighscore != nil {
				if newHighscore == oldHighscore!.score + 1 {
					congratulateAboutNewHighscore()
				}
				wordSelectionTVC!.highscoreCounter!.updateHighscore(word: word, score: score, player: player)
			}
		}
	}
	
	private func congratulateAboutNewHighscore() {
		let ac = UIAlertController(title: "🎊Congratulation!🎊", message: "You beat the previous highscore!👏", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Yeah!", style: .default))
		present(ac, animated: true)
	}
	
	
	// MARK: answer checking
	
	private func isPossible(word: String) -> Bool {
		// TODO: Ignore ^ and ` and all these extra things on top of letters so it works better in languages like French
		let lowercasedWord = word.lowercased()
		var allPossibleLetters = title!.lowercased()
		
		for letter in lowercasedWord {
			if let pos = allPossibleLetters.range(of: String(letter)) {
				allPossibleLetters.remove(at: pos.lowerBound)
			} else {
				return false
			}
		}
		
		return true
	}
	
	private func isOriginal(word: String) -> Bool {
		return !answers.contains(word)
	}
	
	private func isReal(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSMakeRange(0, word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: language.shortWord)
		
		return misspelledRange.location == NSNotFound
	}
	
	private func isLongEnough(word: String) -> Bool {
		return word.utf16.count >= 3
	}
	
	private func isNotSameWord(word: String) -> Bool {
		return word.lowercased() != title!.lowercased()
	}
	
	private func showErrorMessage(title: String, message: String) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}

	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
        	return answers.count
		}
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordGuessingCell", for: indexPath)

		if indexPath.section == 0 {
			cell.textLabel?.text = "Current word count: \(answers.count)"
		} else {
			cell.textLabel?.text = answers[indexPath.row]
		}

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

	
    // MARK: - Navigation
	
	
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		//print("preparing for segue: destination: \(segue.destination); sender: \(sender)")
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		wordSelectionTVC!.tableView.reloadData()
    }
	

}
