//
//  Region.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/19/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

struct XcodeRegion {
	var languageCode: String
	var languageName: String
	var lproj: [String] // Additional lproj format
}

class Region: NSObject {
	var label = ""
	var code = ""
	var files = [File]()
	static let defaultXcodeRegions = Region.knownXcodeRegion()
	
	class func knownXcodeRegion() -> [XcodeRegion] {
		var xcodeRegions = [XcodeRegion]()
		
		// TODO: improve that list
		xcodeRegions.append(XcodeRegion(languageCode: "Base", languageName: "Base", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "af", languageName: "Afrikaans", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "sq", languageName: "Albanian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "ar", languageName: "Arabic", lproj: ["ar"]))
		xcodeRegions.append(XcodeRegion(languageCode: "az", languageName: "Azerbaijani", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "eu", languageName: "Basque", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "be", languageName: "Belarusian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "bn", languageName: "Bengali", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "bs", languageName: "Bosnian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "bg", languageName: "Bulgarian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "ca", languageName: "Catalan", lproj: ["ca"]))
		xcodeRegions.append(XcodeRegion(languageCode: "ceb", languageName: "Cebuano", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "zh", languageName: "Chinese (Simplified)", lproj: ["zh-Hans"]))
		xcodeRegions.append(XcodeRegion(languageCode: "zh-TW", languageName: "Chinese (Traditional)", lproj: ["zh-Hant"]))
		xcodeRegions.append(XcodeRegion(languageCode: "hr", languageName: "Croatian", lproj: ["hr"]))
		xcodeRegions.append(XcodeRegion(languageCode: "cs", languageName: "Czech", lproj: ["cs"]))
		xcodeRegions.append(XcodeRegion(languageCode: "da", languageName: "Danish", lproj: ["da"]))
		xcodeRegions.append(XcodeRegion(languageCode: "nl", languageName: "Dutch", lproj: ["nl"]))
		xcodeRegions.append(XcodeRegion(languageCode: "en", languageName: "English", lproj: ["en", "English"]))
		xcodeRegions.append(XcodeRegion(languageCode: "eo", languageName: "Esperanto", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "et", languageName: "Estonian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "tl", languageName: "Filipino", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "fi", languageName: "Finnish", lproj: ["fi"]))
		xcodeRegions.append(XcodeRegion(languageCode: "fr", languageName: "French", lproj: ["French"]))
		xcodeRegions.append(XcodeRegion(languageCode: "gl", languageName: "Galician", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "ka", languageName: "Georgian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "de", languageName: "German", lproj: ["de"]))
		xcodeRegions.append(XcodeRegion(languageCode: "el", languageName: "Greek", lproj: ["el"]))
		xcodeRegions.append(XcodeRegion(languageCode: "gu", languageName: "Gujarati", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "ht", languageName: "Haitian Creole", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "iw", languageName: "Hebrew", lproj: ["he"]))
		xcodeRegions.append(XcodeRegion(languageCode: "hi", languageName: "Hindi", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "hmn", languageName: "Hmong", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "hu", languageName: "Hungarian", lproj: ["hu"]))
		xcodeRegions.append(XcodeRegion(languageCode: "is", languageName: "Icelandic", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "id", languageName: "Indonesian", lproj: ["id"]))
		xcodeRegions.append(XcodeRegion(languageCode: "ga", languageName: "Irish", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "it", languageName: "Italian", lproj: ["it"]))
		xcodeRegions.append(XcodeRegion(languageCode: "ja", languageName: "Japanese", lproj: ["ja"]))
		xcodeRegions.append(XcodeRegion(languageCode: "jw", languageName: "Javanese", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "kn", languageName: "Kannada", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "km", languageName: "Khmer", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "ko", languageName: "Korean", lproj: ["ko"]))
		xcodeRegions.append(XcodeRegion(languageCode: "lo", languageName: "Lao", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "la", languageName: "Latin", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "lv", languageName: "Latvian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "lt", languageName: "Lithuanian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "mk", languageName: "Macedonian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "ms", languageName: "Malay", lproj: ["ms"]))
		xcodeRegions.append(XcodeRegion(languageCode: "mt", languageName: "Maltese", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "mr", languageName: "Marathi", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "no", languageName: "Norwegian", lproj: ["nb"]))
		xcodeRegions.append(XcodeRegion(languageCode: "fa", languageName: "Persian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "pl", languageName: "Polish", lproj: ["pl"]))
		xcodeRegions.append(XcodeRegion(languageCode: "pt", languageName: "Portuguese", lproj: ["pt", "pt-PT"]))
		xcodeRegions.append(XcodeRegion(languageCode: "ro", languageName: "Romanian", lproj: ["ro"]))
		xcodeRegions.append(XcodeRegion(languageCode: "ru", languageName: "Russian", lproj: ["ru"]))
		xcodeRegions.append(XcodeRegion(languageCode: "sr", languageName: "Serbian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "sk", languageName: "Slovak", lproj: ["sk"]))
		xcodeRegions.append(XcodeRegion(languageCode: "sl", languageName: "Slovenian", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "es", languageName: "Spanish", lproj: ["es"]))
		xcodeRegions.append(XcodeRegion(languageCode: "sw", languageName: "Swahili", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "sv", languageName: "Swedish", lproj: ["sv"]))
		xcodeRegions.append(XcodeRegion(languageCode: "ta", languageName: "Tamil", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "te", languageName: "Telugu", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "th", languageName: "Thai", lproj: ["th"]))
		xcodeRegions.append(XcodeRegion(languageCode: "tr", languageName: "Turkish", lproj: ["tr"]))
		xcodeRegions.append(XcodeRegion(languageCode: "uk", languageName: "Ukrainian", lproj: ["uk"]))
		xcodeRegions.append(XcodeRegion(languageCode: "ur", languageName: "Urdu", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "vi", languageName: "Vietnamese", lproj: ["vi"]))
		xcodeRegions.append(XcodeRegion(languageCode: "cy", languageName: "Welsh", lproj: []))
		xcodeRegions.append(XcodeRegion(languageCode: "yi", languageName: "Yiddish", lproj: []))
		return xcodeRegions
	}
	
	class func regionMatchingString(string: String) -> Region? {
		for xcodeRegion in self.defaultXcodeRegions {
			if xcodeRegion.languageName == string ||
			xcodeRegion.languageCode == string ||
				xcodeRegion.lproj.contains(string) {
					let newRegion = Region()
					newRegion.label = xcodeRegion.languageName
					newRegion.code = xcodeRegion.lproj.count != 0 ? xcodeRegion.lproj[0] : xcodeRegion.languageCode
					
					return newRegion
			}
		}
		return nil
	}
	
	override var description: String {
		get {
			return self.debugDescription
		}
	}
	
	override var debugDescription: String {
		get {
			return "Label: \(self.label)\n" +
				"Code: \(self.code)\n" +
				"File Count: \(self.files.count)\n"
		}
	}

}
