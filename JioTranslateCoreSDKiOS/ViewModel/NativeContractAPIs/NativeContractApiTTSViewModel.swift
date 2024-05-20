//
//  NativeContractApiTTSViewModel.swift
//  JioTranslate
//
//  Created by Ramakrishna1 M on 08/02/24.
//

import Foundation
import AVFoundation
import UIKit

class NativeContractApiTTSViewModel: NSObject, AVAudioPlayerDelegate {
    private(set) var busy: Bool = false
    private(set) var isSpeechStopped: Bool = false

    private var completionHandler: ((_ text: String) -> Void)?
        
    func synthesisToSpeaker(inputText: String, languageCode: SupportedLanguage, gender: String = "", selectedEngine: TranslateEngineType, completion: @escaping (Result<String, CustomError>) -> Void) {
        self.isSpeechStopped = false
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let postData = self.buildPostData(text: inputText, gender: gender, languageCode: languageCode.rawValue, selectedEngine: selectedEngine)
            let headers = ["Authorization": JioTranslateManager.shared.currentJWT, "Content-Type": "application/json", "User-Agent": "iOS", "x-user-id": JioTranslateManager.shared.currentUserGuestID, "x-user-action": "converse", "x-user-identity": JioTranslateManager.shared.phoneNumber]
            
            let response = self.makePOSTRequest(url: ContractAPIPath.tts.rawValue, postData: postData, headers: headers)

            // Get the `audioContent` (as a base64 encoded string) from the response.
            guard let audioContent = response["audioContent"] as? String else {
                if let status = response["audioContent"] as? String, status == "Unauthorized" {
                    completion(.failure(.statusCode(401)))
                    return
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.otherError("")))
                    }
                    self.busy = false
                }
                return
            }
            completion(.success(audioContent))
        }
    }
    
    private func buildPostData(text: String, gender: String, languageCode: String = "", selectedEngine: TranslateEngineType) -> Data {
        let selectedGender = gender.isEmpty ? JioTranslateManager.shared.gender : gender

        let params: [String: Any] = [
            "platform": selectedEngine.rawValue,
            "gender": selectedGender,
            "input": [
                "text": text
            ],
            "language": languageCode,
            "audioConfig": [
                "audioEncoding": "LINEAR16"
            ]
        ]
        // Convert the Dictionary to Data
        let data = (try? JSONSerialization.data(withJSONObject: params)) ?? Data()
        return data
    }
    
    // Just a function that makes a POST request.
    private func makePOSTRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dict
    }
}
