//
//  ViewController.swift
//  JioTranslateCoreSDKDemo
//
//  Created by Ramakrishna1 M on 17/05/24.
//

import UIKit
import JioTranslateCoreSDKiOS
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var speakerMicButton: UIButton!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var translationTextView: PlaceHolderTextView!
    @IBOutlet weak var synthesisToSpeaker: UIButton!
    @IBOutlet weak var translateTextButton: UIButton!
    
    @IBOutlet weak var speakerLanguageLabel: UILabel!
    @IBOutlet weak var listenerLanguageLabel: UILabel!
    
    @IBOutlet weak var speakerLanguageBackView: UIView!
    @IBOutlet weak var listenerLanguageBackView: UIView!

    @IBOutlet weak var listenerLanguageDropdown: UIImageView!
    @IBOutlet weak var speakerLanguageDropdown: UIImageView!

    let audioRecorder = AudioRecorder()
    
    private var player: AVAudioPlayer?
    private(set) var isSpeechStopped: Bool = false
    private var sourceLanguage: SupportedLanguage = .english
    private var translateLanguage: SupportedLanguage = .hindi

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let jwt = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJ1LTBhYmI5ZjJmLTYzNDctNDRhOS04ZGJkLWI2NDE3OWQzMTYzZSIsInRva2VuSWQiOiJvdC0wMmJlOGYwZi0xMGIyLTRkMmEtOTQ2Mi00ZmRlMTkzMDk3NGYiLCJzb3VyY2UiOiJtb2JpbGUiLCJpYXQiOjE3MTYxODUxNDAsImV4cCI6MTcxNjI3MTU0MH0.cxZNGKjvaJkI-ElkfeFnkkPcDCMk6mcdWc9PceCHgxykswBmCYQJwZkcI2P3xAGMEl4NHajFG1QGHYEo_WWK4MCeuma5mj6oUY-fKEf9QWzcGBpHeF4H_4nqiju5JcqeLWjpf---IH53aR0vfXGK8onF1Et6SPt0VA5UqaPeCXk"
        let userId = "u-0abb9f2f-6347-44a9-8dbd-b64179d3163e"
        
        JioTranslateManager.shared.configure(server: .sit, jwt: jwt, userId: userId, gender: "male")
        
        translationTextView.layer.borderColor = UIColor.systemBlue.cgColor
        translationTextView.layer.cornerRadius = 16
        translationTextView.layer.borderWidth = 1
        translationTextView.placeholder = "Translation Text"

        textView.layer.borderColor = UIColor.blue.cgColor
        textView.layer.cornerRadius = 16
        textView.layer.borderWidth = 1
        textView.placeholder = "Input Text"
        
        speakerMicButton.setTitle("Start Recording", for: .normal)
        speakerMicButton.setTitle("Stop Recording", for: .selected)
        
        synthesisToSpeaker.setTitle("Synthesis To Speaker ", for: .normal)
        synthesisToSpeaker.setTitle("Stop Speaker", for: .selected)
        
        let languageTapAction = UITapGestureRecognizer(target: self, action: #selector(didTapLanguageActionFrom(_:)))
        let languageTapAction2 = UITapGestureRecognizer(target: self, action: #selector(didTapLanguageActionTo(_:)))

        speakerLanguageBackView.addGestureRecognizer(languageTapAction)
        listenerLanguageBackView.addGestureRecognizer(languageTapAction2)
    }
    
    @IBAction func didPressSpeakerButtonAction(_ sender: UIButton) {
        self.speakerMicButton.isSelected = !sender.isSelected
        if self.speakerMicButton.isSelected {
            startRecording()
            print("recording started")
        } else {
            audioRecorder.stopRecording()
            print("recording stopped")
        }
    }
    
    @IBAction func didPressSynthesisToSpeakerButtonAction(_ sender: UIButton) {
        self.synthesisToSpeaker.isSelected = !sender.isSelected
        if self.synthesisToSpeaker.isSelected {
            textToSpeech()
        } else {
            print("Synthesis To Speaker Stopped")
            stopSpeech()
        }
    }
    
    @IBAction func didPressTranslateTextAction(_ sender: UIButton) {
        let finalText = textView.text.replacingOccurrences(of: "\n", with: "")
        let isTextEmpty = finalText.replacingOccurrences(of: " ", with: "").isEmpty
        
        if !isTextEmpty {
            JioTranslateManager.shared.translateText(inputText: textView.text ?? "", inputLanguage: sourceLanguage, translationLanguage: translateLanguage) { [weak self] result in
                switch result {
                case .success(let translatedText):
                    guard let self = self else { return }
                    self.translationTextView.text = translatedText
                case .failure(let error):
                    self?.showErrorAlert(for: error)
                }
            }
        }
    }
    
    @objc func didTapLanguageActionFrom(_ sender: UITapGestureRecognizer) {
        let languageVC = LanguageVC()
        let navVC = UINavigationController(rootViewController: languageVC)
        languageVC.didSelectLanguage = { language in
            self.sourceLanguage = language
            self.speakerLanguageLabel.text = language.rawValue
            // Handle the selected language
            print("Selected Language: \(language.rawValue)")
        }
        navVC.modalPresentationStyle = .overCurrentContext
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func didTapLanguageActionTo(_ sender: UITapGestureRecognizer) {
        let languageVC = LanguageVC()
        let navVC = UINavigationController(rootViewController: languageVC)
        languageVC.didSelectLanguage = { language in
            self.translateLanguage = language
            self.listenerLanguageLabel.text = language.rawValue

            // Handle the selected language
            print("Selected Language: \(language.rawValue)")
        }
        navVC.modalPresentationStyle = .overCurrentContext
        present(navVC, animated: true, completion: nil)
    }
}

// MARK: - Speech to Text
extension ViewController {
    func startRecording() {
        let audioFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sound.wav")
        
        audioRecorder.startRecording(url: audioFileURL, maxRecordingTime: 59.0, maxSilenceTime: 0.8, ignoreSilence: true, enableLiveTranslation: false) { [weak self] in
            
            JioTranslateManager.shared.startTextTranslationRecording(audioURL: audioFileURL, inputLanguage: self?.sourceLanguage ?? .english) { result in
                switch result {
                case .success(let text):
                    let finalText = text.replacingOccurrences(of: "\n", with: "")
                    let isTextEmpty = finalText.replacingOccurrences(of: " ", with: "").isEmpty
                    if isTextEmpty {
                        self?.showErrorAlert(withMessage: "Audio is not clear, please try again!")
                    } else {
                        self?.textView.text = text
                    }
                case .failure(let error):
                    self?.showErrorAlert(for: error)
                }
            }
        }
    }
}

// MARK: - Text to Speech
extension ViewController {
    func textToSpeech() {
        JioTranslateManager.shared.synthesisToSpeaker(inputText: self.translationTextView.text, inputLanguage: translateLanguage) { [weak self] result in
            switch result {
            case .success(let text):
                let finalText = text.replacingOccurrences(of: "\n", with: "")
                let isTextEmpty = finalText.replacingOccurrences(of: " ", with: "").isEmpty
                DispatchQueue.main.async {
                    if !isTextEmpty {
                        self?.playTheAudio(audioContent: text)
                    } else {
                        self?.stopSpeech()
                        print("Failed to play the audio")
                    }
                }
            case .failure(let error):
                self?.stopSpeech()
                self?.showErrorAlert(for: error)
                print("Failed to play the audio")

            }
        }
    }
    
    func playTheAudio(audioContent: String) {
        // Decode the base64 string into a Data object
        guard let audioData = Data(base64Encoded: audioContent) else {
            return
        }
        self.player = try? AVAudioPlayer(data: audioData)
        self.player?.delegate = self
        self.player?.play()
    }
    
    func stopSpeech() {
        self.player?.delegate = nil
        self.player = nil
        self.synthesisToSpeaker.isSelected = false
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopSpeech()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("error -->audioPlayerDecodeErrorDidOccur")
    }
}

extension ViewController {
    func showErrorAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Get the root view controller to present the alert
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showErrorAlert(for error: CustomError) {
        switch error {
        case .statusCode(let code):
            if code == 401 {
                showErrorAlert(withMessage: "Unauthorized access (401 error)")
            } else {
                showErrorAlert(withMessage: "Received status code: \(code)")
            }
        case .otherError(let message):
            showErrorAlert(withMessage: "Other error occurred: \(message)")
        @unknown default:
            showErrorAlert(withMessage: "Something went wrong, please try again!")
        }
    }
}
