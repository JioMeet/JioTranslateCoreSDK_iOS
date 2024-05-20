//
//  Enums.swift
//  JioMatrixTranslationSDK
//
//  Created by Ramakrishna1 M on 24/01/24.
//

import Foundation

public enum TranslateEngineType: String {
    case azure = "azure", googleAPI = "google", reverie = "reverie"
    
    var getEngineFullForm: String {
        switch self {
        case .azure: return "azure"
        case .googleAPI: return "googleApi"
        case .reverie: return "reverie"
        }
    }
}

extension String {
    func getEngineType() -> TranslateEngineType {
        switch self {
        case "googleApi":
            return .googleAPI
        case "azure":
            return .azure
        case "reverie":
            return .reverie
            
        default:
            return .googleAPI
        }
    }
    
    func getShortForm() -> String {
        var code = self
        if self.contains("-") {
            let array = self.components(separatedBy: "-")
            code = array.first ?? self
        }
        return code
    }
}

enum ContractAPIPath: String {
    case stt, directTranslation, indriectTranslation, tts, visionDetect
    
    var rawValue: String {
        let currentEnv = JioTranslateManager.shared.currentEnv.rawValue
        switch self {
        case .stt:
            return "https://\(currentEnv)/translator/stt"
        case .directTranslation:
            return "https://\(currentEnv)/translator/direct-translate"
        case .indriectTranslation:
            return "https://\(currentEnv)/translator/indirect-translate"
        case .tts:
            return "https://\(currentEnv)/translator/tts"
        case .visionDetect:
            return "https://\(currentEnv)/translator/vision/detect"
        }
    }
}

// MARK: - HTTP Methods
enum JMHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Server Scheme
enum JMApiServerScheme: String {
    case https = "https"
    case http = "http"
    
    func getUrlValue() -> String {
        switch self {
        case .https:
            return "https://"
        case .http:
            return "http://"
        }
    }
}

// MARK: - Server Environments
public enum JioTranslateServer: String {
    case prod = "translate.jio"
    case sit = "sit.translate.jio"
}

public enum SupportedLanguage: String, CaseIterable {
    case english = "English"
    case hindi = "Hindi"
    case gujarati = "Gujarati"
    case marati = "Marathi"
    case bengali = "Bengali"
    case telugu = "Telugu"
    case kannada = "Kannada"
    case tamil = "Tamil"
    case malayalam = "Malayalam"
    case spanish = "Spanish"
    case french = "French"
    case german = "German"
}

public enum CustomError: Error {
    case statusCode(Int)
    case otherError(String)
}
