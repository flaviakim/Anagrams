//
//  Language.swift
//  Anagrams
//
//  Created by Flavia on 16.11.18.
//  Copyright © 2018 Flavia. All rights reserved.
//

import Foundation

class Language {
	
	let shortWord: String
	let longWord: String
	let isCaseSensitive: Bool
	
	static let allLanguages = [Language(shortWord: "en", longWord: "English"), Language(shortWord: "de", longWord: "German")]
	
	static func getDefaultLanguage() -> Language {
		return allLanguages[0]
	}
	
	private init(shortWord: String, longWord: String, isCaseSensitive: Bool = true) {
		self.shortWord = shortWord
		self.longWord = longWord
		self.isCaseSensitive = isCaseSensitive
	}
	
	static func getLanguageFrom(shortWord: String) -> Language? {
		for language in Language.allLanguages {
			if language.shortWord == shortWord {
				return language
			}
		}
		return nil
	}
	
}
