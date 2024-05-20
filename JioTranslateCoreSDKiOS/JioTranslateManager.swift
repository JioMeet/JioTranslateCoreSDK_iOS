//
//  JioTranslateManager.swift
//  JioTranslateCoreSDKiOS
//
//  Created by Ramakrishna1 M on 17/05/24.
//

import Foundation

public class JioTranslateManager: NSObject {
    public static let shared = JioTranslateManager()
    
    lazy var speechToTextViewModel = SpeechToTextViewModel()
    lazy var textToTextViewModel = TextToTextViewModel()
    lazy var textToSpeachViewModel = TextToSpeachViewModel()
    
    var currentEnv = JioTranslateServer.prod
    var currentJWT = ""
    var currentUserGuestID = ""
    var phoneNumber = ""
    var gender = "male"
    
    public func configure(server: JioTranslateServer, jwt: String, userId: String, gender: String) {
        self.currentEnv = server
        self.currentJWT = jwt
        self.currentUserGuestID = userId
        self.gender = gender
    }
    
    public func startTextTranslationRecording(audioURL: URL, inputLanguage: SupportedLanguage, translateEngine: TranslateEngineType = .googleAPI, completion: @escaping (Result<String, CustomError>) -> Void) {

        speechToTextViewModel.startTextTranslationRecording(audioURL: audioURL, inputLanguage: inputLanguage, completion: completion)
    }
    
    public func translateText(inputText: String, inputLanguage: SupportedLanguage, translationLanguage: SupportedLanguage, translateEngine: TranslateEngineType = .googleAPI, isIndirectTranslation: Bool = false, completion: @escaping (Result<String, CustomError>) -> Void) {
        textToTextViewModel.translateText(inputText: inputText, inputLanguage: inputLanguage, translationLanguage: translationLanguage, completion: completion)
    }
    
    public func synthesisToSpeaker(inputText: String, inputLanguage: SupportedLanguage, translateEngine: TranslateEngineType = .googleAPI, gender: String = "male", completion: @escaping (Result<String, CustomError>) -> Void) {
        textToSpeachViewModel.synthesisToSpeaker(inputText: inputText, inputLanguage: inputLanguage, completion: completion)
    }
}
