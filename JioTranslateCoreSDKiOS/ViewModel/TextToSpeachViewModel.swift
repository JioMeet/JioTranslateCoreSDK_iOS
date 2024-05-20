//
//  TextToSpeachViewModel.swift
//  JioTranslate
//
//  Created by Ramakrishna1 M on 22/12/23.
//

import Foundation
import AVFoundation
import UIKit

 class TextToSpeachViewModel: NSObject, AVAudioPlayerDelegate {
    private lazy var nativeContractApiTTSViewModel = NativeContractApiTTSViewModel()
    
    override init() { }

     func synthesisToSpeaker(inputText: String, inputLanguage: SupportedLanguage, translateEngine: TranslateEngineType = .googleAPI, gender: String = "male", completion: @escaping (Result<String, CustomError>) -> Void) {
         if inputText.contains("*****") {
             completion(.failure(.otherError("")))
             return
         }
         nativeContractApiTTSViewModel.synthesisToSpeaker(inputText: inputText, languageCode: inputLanguage, gender: gender, selectedEngine: translateEngine, completion: completion)
     }
}

