//
// Created by Eric Lightfoot on 2021-09-02.
//

import Foundation
import SoundAnalysis
import CoreML

class FFSoundAnalyzer: FFAnalyzer {
    static let shared = FFSoundAnalyzer()

    private var audioEngine: AVAudioEngine
    private var inputBus: Int
    private var inputFormat: AVAudioFormat
    private var streamAnalyzer: SNAudioStreamAnalyzer
    private var resultsObserver: ResultsObserver

    private let analysisQueue = DispatchQueue(label: "com.flightfu.AnalysisQueue")

    private override init () {
        // Create a new audio engine.
        audioEngine = AVAudioEngine()
        // Get the native audio format of the engine's input bus.
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        // Create a new stream analyzer.
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        // Create results observer and keep strong reference
        resultsObserver = ResultsObserver()
    }

    override func start (events: FFEventEmitter) {
        super.start(events: events)

        // Create result observer
        do {
            let request = try getRequest()
            // Add the sound analysis request to the stream analyzer with the result observer
            try streamAnalyzer.add(request, withObserver: resultsObserver)
        } catch (let err) {
            print("Unable to set up analyzer: \(err.localizedDescription)")
        }
        
        // Install tap to route audio buffer to stream analyzer
        audioEngine.inputNode.installTap(onBus: inputBus,
                bufferSize: 8192,
                format: inputFormat,
                block: analyzeAudio(buffer:at:))
        
        startAudioEngine()
    }

    private func startAudioEngine() {
        do {
            // Start the stream of audio data.
            try audioEngine.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }

    private func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }

    private func getRequest () throws -> SNClassifySoundRequest {
        // Get the model
        let soundClassifier = try MySoundClassifier_1(configuration: MLModelConfiguration())
        // Create a classify sound request that uses the custom sound classifier.
        return try SNClassifySoundRequest(mlModel: soundClassifier.model)
    }
}

// An observer that receives results from a classify sound request.
class ResultsObserver: NSObject, SNResultsObserving {
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
        let percent = classification.confidence * 100.0
        let percentString = String(format: "%.2f%%", percent)

        // Print the classification's name (label) with its confidence.
        print("\(classification.identifier): \(percentString) confidence.\n")
    }


    /// Notifies the observer when a request generates an error.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }

    /// Notifies the observer when a request is complete.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
