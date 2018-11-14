//
//  Highscore.swift
//  Anagrams
//
//  Created by Flavia on 14.11.18.
//  Copyright © 2018 Flavia. All rights reserved.
//

import Foundation

class Highscore: NSObject, NSCoding {
	
	override public var description: String {
		return "word: \(word); score: \(score); name: \(name)"
	}
	
	let word: String
	let score: Int
	let name: String
	
	init(word: String, score: Int, name: String) {
		self.word = word
		self.score = score
		self.name = name
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.word = aDecoder.decodeObject(forKey: "word") as! String
		self.score = aDecoder.decodeInteger(forKey: "score")
		self.name = aDecoder.decodeObject(forKey: "name") as! String
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(word, forKey: "word")
		aCoder.encode(score, forKey: "score")
		aCoder.encode(name, forKey: "name")
	}
	
}
