//
// Created by Eric Lightfoot on 2021-09-02.
//

import Foundation
import Combine
import Accelerate
import SoundAnalysis
import CoreML

enum CoreMLClassificationIdentifiers {
    case secure, running
}

class FFSoundAnalyzer: FFAnalyzer, ObservableObject {
    static let shared = FFSoundAnalyzer()
    
    @Published var error: FFError?
    @Published var classificationIdentifier: CoreMLClassificationIdentifiers = .secure
    @Published var micAmplitude: Float = 0.0

    private var audioEngine: AVAudioEngine
    private var inputBus: Int
    private var inputFormat: AVAudioFormat
    private var streamAnalyzer: SNAudioStreamAnalyzer
    private var resultsObserver: ResultsObserver?

    private let analysisQueue = DispatchQueue(label: "com.flightfu.AnalysisQueue")

    private override init () {
        // Create a new audio engine.
        audioEngine = AVAudioEngine()
        // Get the native audio format of the engine's input bus.
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        // Create a new stream analyzer.
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        super.init()

        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(audioEngine.inputNode, to: mixer, format: inputFormat)

        // Install tap to route audio buffer to stream analyzer
        audioEngine.inputNode.installTap(onBus: inputBus,
                bufferSize: 8192,
                format: inputFormat,
                block: analyzeAudio(buffer:at:))

        // Install tap to measure mic input amplitude
        mixer.installTap(onBus: inputBus,
                bufferSize: 4096,
                format: mixer.inputFormat(forBus: inputBus),
                block: getAmplitude(buffer:at:))
    }

    override func start (events: FFEventEmitter) {
        super.start(events: events)

        // Create results observer and keep strong reference
        resultsObserver = ResultsObserver { result, confidence in
            if case .failure(let error) = result {
                self.analyzingFailed(error)
            } else if case .success(let value) = result {
                if value == "running" && confidence > 95 && self.micAmplitude > 0.28 {
                    self.engineStarted()
                } else if value == "secure" && confidence > 95 {
                    self.engineStopped()
                }
            }
        }
        
        do {
            let request = try getRequest()
            // Add the sound analysis request to the stream analyzer with the result observer
            try streamAnalyzer.add(request, withObserver: resultsObserver!)
        } catch (let error) {
            print("Unable to set up analyzer: \(error.localizedDescription)")
            analyzingFailed(FFError(error))
        }

        do {
            // Start the stream of audio data.
            try audioEngine.start()
        } catch (let error) {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
            analyzingFailed(FFError(error))
        }
    }

    private func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }

    private func getAmplitude(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            guard let floatData = buffer.floatChannelData else { return }

            let channelCount = Int(buffer.format.channelCount)
            let length = UInt(buffer.frameLength)

            // n is the channel
            for n in 0 ..< channelCount {
                let data = floatData[n]

                var rms: Float = 0
                vDSP_rmsqv(data, 1, &rms, UInt(length))
                DispatchQueue.main.async {
                    self.micAmplitude = rms
                }
            }
        }
    }

    private func getRequest () throws -> SNClassifySoundRequest {
        // Get the model
        let soundClassifier = try CessnaEngine(configuration: MLModelConfiguration())
        // Create a classify sound request that uses the custom sound classifier.
        return try SNClassifySoundRequest(mlModel: soundClassifier.model)
    }

    private func engineStarted () {
        DispatchQueue.main.async {
            self.classificationIdentifier = .running
        }
        events.forEach { $0.send(.engineStart) }
    }

    private func engineStopped () {
        DispatchQueue.main.async {
            self.classificationIdentifier = .secure
        }
        events.forEach { $0.send(.engineStop) }
    }

    private func analyzingFailed (_ error: FFError) {
        DispatchQueue.main.async {
            self.error = error
        }
        events.forEach { $0.send(.error(error)) }
    }
    
    // An observer that receives results from a classify sound request.
    private class ResultsObserver: NSObject, SNResultsObserving {
        private var update: (Result<String, FFError>, Double) -> ()
        
        init (update: @escaping (Result<String, FFError>, Double) -> ()) {
            self.update = update
        }
        
        /// Notifies the observer when a request generates a prediction.
        func request(_ request: SNRequest, didProduce result: SNResult) {
            // Downcast the result to a classification result.
            guard let result = result as? SNClassificationResult else  { return }

            // Get the prediction with the highest confidence.
            guard let classification = result.classifications.first else { return }

            // Get the starting time.
            let timeInSeconds = result.timeRange.start.seconds

            // Convert the time to a human-readable string.
            let formattedTime = String(format: "%.2f", timeInSeconds)
            print("Analysis result for audio at time: \(formattedTime)")

            // Convert the confidence to a percentage string.
            let percentConfident = classification.confidence * 100.0
            let percentString = String(format: "%.0f%", percentConfident)

            // Print the classification's name (label) with its confidence.
            print("\(classification.identifier): \(percentString) confidence.\n")
        
            // Let parent class know
            let success = Result<String, FFError>.success(classification.identifier)
            update(success, percentConfident)
        }

        /// Notifies the observer when a request generates an error.
        func request(_ request: SNRequest, didFailWithError error: Error) {
            print("The the analysis failed: \(error.localizedDescription)")
            let failure = Result<String, FFError>.failure(FFError(error))
            update(failure, 100) // 1 Hundo P
        }

        /// Notifies the observer when a request is complete.
        func requestDidComplete(_ request: SNRequest) {
            print("The request completed successfully!")
            assert(false, "This should not execute")
        }
    }
}
