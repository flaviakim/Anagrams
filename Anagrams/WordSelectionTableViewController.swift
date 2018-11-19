//
//  WordSelectionTableViewController.swift
//  Anagrams
//
//  Created by Flavia on 14.11.18.
//  Copyright © 2018 Flavia. All rights reserved.
//

import UIKit

class WordSelectionTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	
	//MARK: Properties
	
	private(set) var highscoreCounter: HighscoreCounter?
	let newWordSection = 0
	let savedWordsSection = 1
	
	let settings = Settings()
	
	func getPlayerName() -> String {
		return settings.playerName
	}
	
	func setPlayerName(newName: String) {
		settings.playerName = newName
		navigationItem.leftBarButtonItem?.title = newName
		if settings.colorCodeLinesForPlayer {
			tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
		}
	}
	
	private var randomWords = [String]()
	func getRandomWord() -> String? {
		return randomWords.randomElement()
	}
	
	//MARK: Initialisation
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		navigationItem.rightBarButtonItem = self.editButtonItem
		title = "Choose word"
		tableView.delegate = self
		tableView.dataSource = self
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: getPlayerName(), style: .plain, target: self, action: #selector(askAboutName))
		
		let defaults = UserDefaults.standard
		if let savedHighscore = defaults.object(forKey: "highscore") as? Data {
			if let decodedHighscore = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedHighscore) as? HighscoreCounter {
				highscoreCounter = decodedHighscore ?? HighscoreCounter()
			}
		}
		if highscoreCounter == nil {
			highscoreCounter = HighscoreCounter()
		}
		
		loadRandomWords()
		removeUsedRandomWords()
		
		askAboutName()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		tableView.reloadData()
	}
	
	private func loadRandomWords() {
		if let randomWordsPath = Bundle.main.path(forResource: "randomWords", ofType: "txt") {
			if let loadedRandomWords = try? String(contentsOfFile: randomWordsPath) {
				randomWords = loadedRandomWords.components(separatedBy: "\n")
			}
		}
		if randomWords.isEmpty {
			randomWords = ["defaults"]
		}
	}
	
	private func removeUsedRandomWords() {
		if let allUsedWords = highscoreCounter?.getAllHighscoreWords() {
			for (index, word) in randomWords.enumerated() {
				for usedWord in allUsedWords {
					if word == usedWord {
						randomWords.remove(at: index)
					}
				}
			}
		}
	}
	
	@objc private func askAboutName() {
		let ac = UIAlertController(title: "Set your name", message: nil, preferredStyle: .alert)
		ac.addTextField()
		ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] action in
			if let newName = ac.textFields![0].text {
				if !newName.isEmpty {
					self.setPlayerName(newName: newName)
				}
			}
		})
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(ac, animated: true)
	}
	
	func save() {
		if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: highscoreCounter!, requiringSecureCoding: false) {
			let defaults = UserDefaults.standard
			defaults.set(savedData, forKey: "highscore")
		}
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	/*override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return ["New Word", "Already Played Words"]
	}*/
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == newWordSection {
			return 2
		}
		return highscoreCounter!.getNumberOfHighscores()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == newWordSection {
			let cell = tableView.dequeueReusableCell(withIdentifier: "NewWordCell", for: indexPath)
			if indexPath.row == 0 {
				cell.textLabel?.text = "New Random Word"
			} else if indexPath.row == 1 {
				cell.textLabel?.text = "New Custom Word"
			}
			return cell
			
		} else if indexPath.section == savedWordsSection {
			let cell = tableView.dequeueReusableCell(withIdentifier: "WordSelectionCell", for: indexPath)
			if let hs = highscoreCounter!.getHighscore(at: indexPath.row) {
				cell.textLabel?.text = hs.word
				cell.detailTextLabel?.text = "highscore: \(hs.score) by \(hs.player)"
				if settings.colorCodeLinesForPlayer {
					if hs.player == getPlayerName() {
						cell.backgroundColor = UIColor(red: 0.95, green: 1, blue: 0.95, alpha: 1)
					} else {
						cell.backgroundColor = UIColor(red: 1, green: 0.92, blue: 0.92, alpha: 1)
					}
				}
			}
			return cell
			
		}
		print("ERROR: WordSelectionTableViewController::cellForRowAt")
		return UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "MainGameTVC", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 0 {
			return false
		}
		return true
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		assert (indexPath.section == 1)
		if editingStyle == .delete {
			// Delete the row from the data source
			highscoreCounter!.removeHighscore(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
			save()
		}
	}
	
	
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
	
	
	// MARK: Picker View Data and Delegate
	// Not currently used, but might switch from automatic language detection to either asking the player always or when the custom word is unused.
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return Language.allLanguages.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return Language.allLanguages[row].longWord
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		//language = Language.allLanguages[row]
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "MainGameTVC" {
			if let mainGameVC = segue.destination as? MainGameTableViewController {
				mainGameVC.wordSelectionTVC = self
				if let indexPath = tableView.indexPathForSelectedRow {
					if indexPath.section == 0 {
						if indexPath.row == 0 {
							mainGameVC.title = getRandomWord()
						} else if indexPath.row == 1 {
							// if we don't set the title of the mainGameVC it should ask the player automaticaly so we don't do anything.
						}
						mainGameVC.isNewWord = true
					} else if indexPath.section == 1 {
						let hs = highscoreCounter!.getHighscore(at: indexPath.row)!
						mainGameVC.title = hs.word
						mainGameVC.oldHighscore = hs
						mainGameVC.isNewWord = false
						mainGameVC.language = hs.language
					}
				}
			}
		}
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
	}
	
	
}
