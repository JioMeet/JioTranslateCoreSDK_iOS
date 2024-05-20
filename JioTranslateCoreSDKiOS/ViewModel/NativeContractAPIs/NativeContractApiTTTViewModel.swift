//
//  NativeContractApiTTTViewModel.swift
//  JioTranslate
//
//  Created by Ramakrishna1 M on 08/02/24.
//

import Foundation

class NativeContractApiTTTViewModel {
    func translateText(_ text: String, sourceLanguage: SupportedLanguage, targetLanguage: SupportedLanguage, isInDirectTransaltion: Bool, selectedEngine: TranslateEngineType, completion: @escaping (Result<String, CustomError>) -> Void) {
        guard sourceLanguage != targetLanguage else {
            completion(.success(text))
            return
        }

        var parameters = [
            "platform": selectedEngine.rawValue,
            "q": text,
            "source_language": sourceLanguage.rawValue,
            "target_language": targetLanguage.rawValue
        ]
        let enableIndirectTranslation = sourceLanguage.rawValue != "English" && targetLanguage.rawValue != "English" && isInDirectTransaltion
        
        if enableIndirectTranslation  {
            parameters["indirect_language"] = "English"
        }
        
        let tttAPIPath = enableIndirectTranslation ? ContractAPIPath.indriectTranslation.rawValue : ContractAPIPath.directTranslation.rawValue
        
        let postData = try? JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: URL(string: tttAPIPath)!, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(JioTranslateManager.shared.currentJWT, forHTTPHeaderField: "Authorization")
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        request.addValue(JioTranslateManager.shared.currentUserGuestID, forHTTPHeaderField: "x-user-id")
        request.addValue("text", forHTTPHeaderField: "x-user-action")
        request.addValue(JioTranslateManager.shared.phoneNumber , forHTTPHeaderField: "x-user-identity")

        request.httpMethod = "POST"
        request.httpBody = postData
        
        let requestStartTime = Date()
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    // Handle non-HTTP response
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(.statusCode(401)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.otherError(error?.localizedDescription ?? "")))
                    return
                }
                
                // Convert Data to String using UTF-8 encoding
                if let stringData = String(data: data, encoding: .utf8) {
                    // Handle the string data as needed
//                    print("String data:", stringData)
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let status = jsonResponse?["status"] as? String, status == "success", let translatedText = jsonResponse?["translated_text"] as? String  {
                        var updatedString = translatedText.replacingOccurrences(of: "&#39;", with: "'")
                        updatedString = updatedString.replacingOccurrences(of: "&#38;", with: "&")
                        
                        let timeTakenInSeconds = Date().timeIntervalSince(requestStartTime)
                        completion(.success(updatedString))
                    }
                } catch {
//                    print("Error parsing JSON: \(error.localizedDescription)")
                    completion(.failure(.otherError(error.localizedDescription)))
                }
            }
        }
        
        task.resume()
    }
    
    func logError(response: URLResponse?, error: String) {
        // Check if response is an HTTPURLResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid HTTP response")
            return
        }
    }
}
