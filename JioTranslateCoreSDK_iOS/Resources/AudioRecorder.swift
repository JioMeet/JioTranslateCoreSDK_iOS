//
//  AudioRecorder.swift
//  JioTranslateCoreSDKDemo
//
//  Created by Ramakrishna1 M on 17/05/24.
//

import Foundation
import AVFoundation

class AudioRecorder {
    var silenceThreshold: Float = -40.0
    var outsideTimer: Timer?
    var silenceTimer: Timer?
    var continuousSilenceDuration: TimeInterval = 0.0
    var userHasSpoken = false
    var audioRecorder: AVAudioRecorder?
    var callback: (() -> Void)? = nil
    var silenceDetectedCallback: (() -> Void)?
    var enableLiveTranslation: Bool = false
    
    init() {}

    func startRecording(url: URL, maxRecordingTime: TimeInterval, maxSilenceTime: TimeInterval, ignoreSilence: Bool, enableLiveTranslation: Bool, callback: (() -> Void)? = nil) {
        do {
            let recordingSettings: [String: Any] = [
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                AVEncoderBitRateKey: 16,
                AVNumberOfChannelsKey: 1,
                AVSampleRateKey: 16000
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: recordingSettings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error:", error.localizedDescription)
            return
        }

        audioRecorder?.record()

        outsideTimer?.invalidate()
        outsideTimer = Timer.scheduledTimer(withTimeInterval: maxRecordingTime, repeats: false) { [weak self] _ in
            self?.stopRecording()
        }
        self.callback = callback
        self.enableLiveTranslation = enableLiveTranslation
        guard !ignoreSilence || enableLiveTranslation else { return }
        startRecordingPhase(maxSilenceTime: maxSilenceTime)
    }

    func stopRecording() {
        guard let audioRecorder = audioRecorder, audioRecorder.isRecording else { return }

        audioRecorder.stop()
        self.audioRecorder = nil
        userHasSpoken = false
        outsideTimer?.invalidate()
        outsideTimer = nil
        silenceTimer?.invalidate()
        silenceTimer = nil
        continuousSilenceDuration = 0.0
        callback?()
    }
    
    private func startRecordingPhase(maxSilenceTime: TimeInterval) {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.audioRecorder?.updateMeters()
            self.handleAudioMeterUpdate(maxSilenceTime: maxSilenceTime, timer: timer)
        }
    }

    private func handleAudioMeterUpdate(maxSilenceTime: TimeInterval, timer: Timer) {
        guard let averagePower = self.audioRecorder?.averagePower(forChannel: 0) else { return }

//        print("Estimated Noise Level: \(averagePower), Dynamic Threshold: \(self.silenceThreshold)")

        if averagePower > self.silenceThreshold {
//            print("User is speaking")
            self.userHasSpoken = true
            self.continuousSilenceDuration = 0.0
        } else {
//            print("User is not speaking (silence)")
            self.continuousSilenceDuration += 0.1
            
            if self.enableLiveTranslation {
                self.enableLiveSpeechTranslationOnPauseDetection()
            } else {
                self.handleSilenceDetection(maxSilenceTime: maxSilenceTime, timer: timer)
            }
        }
    }
    
    private func enableLiveSpeechTranslationOnPauseDetection() {
        if self.continuousSilenceDuration > 0.5 && self.userHasSpoken {
            self.userHasSpoken = false
            self.silenceDetectedCallback?()
        }
    }

    private func handleSilenceDetection(maxSilenceTime: TimeInterval, timer: Timer) {
        if self.continuousSilenceDuration >= maxSilenceTime && self.userHasSpoken {
            self.stopRecording()
            timer.invalidate()
        } else if self.continuousSilenceDuration >= 2.0 && !self.userHasSpoken {
            NSLog("Continuous silence for 2 seconds detected.")
            self.stopRecording()
            timer.invalidate()
        }
    }
}
