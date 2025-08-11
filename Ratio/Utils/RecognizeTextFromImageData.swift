//
//  RecognizeTextFromImageData.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 11..
//

import Vision
import ImageIO

@MainActor
func recognizeTextFromImageData(_ imageData: Data, onUpdate: @escaping @MainActor (String) -> Void) {
    onUpdate("Scanning...")
    DispatchQueue.global(qos: .userInitiated).async {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            Task { @MainActor in onUpdate("OCR failed") }
            return
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let orientation: CGImagePropertyOrientation? = {
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                  let raw = properties[kCGImagePropertyOrientation] as? UInt32,
                  let value = CGImagePropertyOrientation(rawValue: raw) else { return nil }
            return value
        }()

        let handler: VNImageRequestHandler
        if let orientation {
            handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        } else {
            handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        }

        do {
            try handler.perform([request])
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let fullText = observations.compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            if fullText.isEmpty {
                Task { @MainActor in onUpdate("No text found") }
            } else {
                sendGptRequest(prompt: fullText) { jsonResponse in
                    Task { @MainActor in
                        if let jsonResponse = jsonResponse {
                            onUpdate("\(jsonResponse)")
                        } else {
                            onUpdate("Failed to get a gpt response")
                        }
                    }
                }
            }
        } catch {
            Task { @MainActor in onUpdate("OCR failed") }
        }
    }
}
