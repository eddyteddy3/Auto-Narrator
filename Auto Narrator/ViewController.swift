//
//  ViewController.swift
//  Auto Narrator
//
//  Created by Moazzam Tahir on 22/09/2019.
//  Copyright © 2019 Moazzam Tahir. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var avAudio: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var transcribe: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isUserInteractionEnabled = false
        initAudioRecorder()
        requestTranscribePermission()
    }
    
    func requestTranscribePermission() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.transcribe.isHidden = false
                    print("Good to go")
                } else {
                    print("Not granted")
                }
            }
        }
    }
    
    func initAudioRecorder(){
        stopButton.isEnabled = false
        playButton.isEnabled = false
        
        let fileMng = FileManager.default
        let path = fileMng.urls(for: .documentDirectory, in: .userDomainMask)
        
        let audioFilePath = path[0].appendingPathComponent("sound.caf")
        let recordingSettings = [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String: Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: audioFilePath, settings: recordingSettings)
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("Error saving \(error.localizedDescription)")
        }
    }

    @IBAction func transcribeSpeech(_ sender: Any) {
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: audioRecorder!.url)
        
        recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            print("Transcribed Audio: \(result?.bestTranscription.formattedString)")
            self.textView.text = result?.bestTranscription.formattedString
        })
    }
    
    @IBAction func record(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            playButton.isEnabled = false
            stopButton.isEnabled = true
            audioRecorder?.record()
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        stopButton.isEnabled = false
        playButton.isEnabled = true
        recordButton.isEnabled = true
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        } else {
            avAudio?.stop()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    @IBAction func play(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            recordButton.isEnabled = false
            stopButton.isEnabled = true
            
            do {
                try avAudio = AVAudioPlayer(contentsOf: audioRecorder!.url)
                avAudio?.delegate = self
                avAudio?.prepareToPlay()
                avAudio?.play()
            } catch let err as NSError {
                print("Error playing audio: \(err.localizedDescription)")
            }
        }
    }
}

