//
//  ChooseProjectViewController+Parser.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/14/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Foundation

extension ChooseProjectViewController {
	
	func parseTranslations(rawContent: String) -> [Translation] {
		let lines = rawContent.componentsSeparatedByString("\n")
		var translations = [Translation]()
		var comments = ""
		
		for line in lines {
			if line.characters.count == 0 {
				continue
			}
			if line.characters.first !=  "\"" { // Comment line or blank lines
				comments.appendContentsOf(line)
				comments.appendContentsOf("\n")
			} else { // line with key
				let translation = self.splitStringLine(line)
				
				translation.comments = comments
				translations.append(translation)
				comments = ""
			}
		}
		return translations
	}
	
	func splitStringLine(line: String) -> Translation {
		var foundFirstQuote = false
		var foundSecondQuote = false
		var foundThirdQuote = false
		let foundLastQuote = false
		var ignoreNextCharacter = false
		
		var key = ""
		var value = ""
		
		for index in 0..<line.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
			let character = line[line.startIndex.advancedBy(index)]
			
			if character == "\\" {
				if !ignoreNextCharacter {
					ignoreNextCharacter = true
					continue
				}
			}
			
			if !foundFirstQuote	{
				if !ignoreNextCharacter {
					if character == "\"" {
						foundFirstQuote = true
						ignoreNextCharacter = false
						continue
					}
				}
			} else {
				if !foundSecondQuote {
					if !ignoreNextCharacter {
						if character == "\"" {
							foundSecondQuote = true
							ignoreNextCharacter = false
							continue
						}
					} else {
						key += "\\"
					}
					
					key += "\(character)"
				} else {
					if !foundThirdQuote {
						if character == " " || character == "=" {
							ignoreNextCharacter = false
							continue
						}
						if character == "\"" {
							foundThirdQuote = true
							ignoreNextCharacter = false
							continue
						}
					} else {
						if !foundLastQuote {
							if !ignoreNextCharacter {
								if character == "\"" {
									foundSecondQuote = true
									ignoreNextCharacter = false
									break
								}
							} else {
								value += "\\"
							}
							
							value += "\(character)"
							
						} else {
							break
						}
					}
				}
			}
			ignoreNextCharacter = false
		}
		
		return Translation(key: key, value: value, comments: "")
	}

}
