//
//  SpeachToTextViewModel.swift
//  JioTranslate
//
//  Created by Ramakrishna1 M on 22/12/23.
//

import Foundation
import AVFoundation

class SpeechToTextViewModel {
    private lazy var nativeContractApiSTSViewModel = NativeContractApiSTSViewModel()
    
    init() { }
    
    func startTextTranslationRecording(audioURL: URL, inputLanguage: SupportedLanguage, translateEngine: TranslateEngineType = .googleAPI, completion: @escaping (Result<String, CustomError>) -> Void) {
        
        nativeContractApiSTSViewModel.recognizeFromMic(audioFileURL: audioURL, language: inputLanguage, selectedEngine: translateEngine, completion: completion)
    }
}

