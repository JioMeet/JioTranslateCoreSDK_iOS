//
//  TextToTextViewModel.swift
//  JioTranslate
//
//  Created by Ramakrishna1 M on 22/12/23.
//

import Foundation

 class TextToTextViewModel {
    private lazy var nativeContractApiTTTViewModel = NativeContractApiTTTViewModel()
    
     init() { }

     func translateText(inputText: String, inputLanguage: SupportedLanguage, translationLanguage: SupportedLanguage, translateEngine: TranslateEngineType = .googleAPI, isIndirectTranslation: Bool = false, completion: @escaping (Result<String, CustomError>) -> Void) {
        nativeContractApiTTTViewModel.translateText(inputText, sourceLanguage: inputLanguage, targetLanguage: translationLanguage, isInDirectTransaltion: isIndirectTranslation, selectedEngine: translateEngine, completion: completion)
    }
}
