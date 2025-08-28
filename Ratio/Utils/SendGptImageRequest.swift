//
//  SendGptImageRequest.swift
//  Ratio
//
//  Created by Assistant on 2025. 08. 11..
//

import Foundation
 

struct ParsedBeanInfo {
    let name: String?
    let roaster: String?
    let origin: Origin?
    let processing: Processing?
}

private struct CoffeeBeanInfo: Decodable {
    let name: String?
    let roaster: String?
    let origin: String?
    let processing: String?
}

/// Sends an image to the OpenAI Responses API (gpt-5-nano) and asks it to extract
/// structured fields from a coffee bean bag: name, roaster, origin, processing.
/// The completion returns the parsed pieces mapped to app enums, or nil on failure.
func sendGptImageRequest(imageData: Data, completion: @escaping (ParsedBeanInfo?) -> Void) {
    let apiKey = "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"

    guard let url = URL(string: "https://api.openai.com/v1/responses") else {
        completion(nil)
        return
    }

    let instruction = "First, decide if the image provided is a coffee bean bag label with text printed on it. If the image has no text, stop and return null for all values. If the image is not a coffee bean bag label, stop and return null for all values. If you're sure it is a bean bag with text, extract information that is printed on it: name, roaster, origin, processing. Only return values that you recognised as text written on the bag label. Don't add notes or commentary, just the extracted text or null."

    // Build data URI for the image
    let mimeType = guessMimeType(for: imageData)
    let base64 = imageData.base64EncodedString()
    let dataURL = "data:\(mimeType);base64,\(base64)"

    // Enum lists from app models (excluding "Not set")
    let originValues: [String] = Origin.allCases.filter { $0 != .notSet }.map { $0.rawValue }
    let processingValues: [String] = Processing.allCases.filter { $0 != .notSet }.map { $0.rawValue }
    var originEnum: [Any] = originValues
    originEnum.append(NSNull())
    var processingEnum: [Any] = processingValues
    processingEnum.append(NSNull())

    // Strict JSON schema definition
    let schema: [String: Any] = [
        "type": "object",
        "properties": [
            "name": ["type": "string", "nullable": true, "description": "Name of the coffee, or null if not confidently recognized"],
            "roaster": ["type": "string", "nullable": true, "description": "Roaster name, or null if not confidently recognized"],
            "origin": [
                "type": ["string", "null"],
                "nullable": true,
                "description": "Origin country from a fixed list, or null if not confidently recognized",
                "enum": originEnum
            ],
            "processing": [
                "type": ["string", "null"],
                "nullable": true,
                "description": "Processing method from a fixed list, or null if not confidently recognized",
                "enum": processingEnum
            ]
        ],
        "required": ["name", "roaster", "origin", "processing"],
        "additionalProperties": false
    ]

    // text.format options for strict JSON schema
    let textOptions: [String: Any] = [
        "format": [
            "type": "json_schema",
            "name": "CoffeeBeanInfo",
            "schema": schema,
            "strict": true
        ]
    ]

    // Compose input with instruction text and image
    let input: [[String: Any]] = [[
        "role": "user",
        "content": [
            ["type": "input_text", "text": instruction],
            ["type": "input_image", "image_url": dataURL]
        ]
    ]]

    // Build request body
    let body: [String: Any] = [
        "model": "gpt-5-nano",
        "input": input,
        "text": textOptions
    ]

    // Serialize to JSON
    guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = httpBody

    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
            print("sendGptImageRequest error: \(error)")
            DispatchQueue.main.async { completion(nil) }
            return
        }
        guard let data = data else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        // Parse structured JSON if present, else fallback like the text function
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let root = jsonObject as? [String: Any] {
                var contentsList: [[[String: Any]]] = []
                if let outputArr = root["output"] as? [[String: Any]] {
                    for element in outputArr {
                        if let content = element["content"] as? [[String: Any]] {
                            contentsList.append(content)
                        }
                    }
                } else if let outputObj = root["output"] as? [String: Any],
                          let content = outputObj["content"] as? [[String: Any]] {
                    contentsList.append(content)
                }

                // Prefer structured JSON block
                for content in contentsList {
                    if let jsonItem = content.first(where: { ($0["type"] as? String) == "output_json" }),
                       let jsonDict = jsonItem["json"] {
                        // Convert dict -> Data -> decode
                        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                        if let parsed = decodeAndMap(data: data) {
                            DispatchQueue.main.async { completion(parsed) }
                            return
                        }
                    }
                }

                // Fallback to text; if it looks like JSON, parse it
                for content in contentsList {
                    if let textItem = content.first(where: { ($0["type"] as? String) == "output_text" }),
                       let text = textItem["text"] as? String {
                        if let textData = text.data(using: .utf8),
                           let parsed = decodeAndMap(data: textData) {
                            DispatchQueue.main.async { completion(parsed) }
                        } else {
                            DispatchQueue.main.async { completion(nil) }
                        }
                        return
                    }
                }
            }

            // Last resort: return nil
            DispatchQueue.main.async { completion(nil) }
        } catch {
            print("sendGptImageRequest parse error: \(error)")
            DispatchQueue.main.async { completion(nil) }
        }
    }
    task.resume()
}

private func guessMimeType(for data: Data) -> String {
    // PNG signature: 89 50 4E 47 0D 0A 1A 0A
    let pngSig: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    if data.count >= 8 {
        let prefix = [UInt8](data.prefix(8))
        if prefix == pngSig {
            return "image/png"
        }
    }
    // JPEG SOI marker: FF D8
    if data.count >= 2 {
        let prefix2 = [UInt8](data.prefix(2))
        if prefix2[0] == 0xFF && prefix2[1] == 0xD8 {
            return "image/jpeg"
        }
    }
    return "image/jpeg"
}

// MARK: - Mapping helpers

private func decodeAndMap(data: Data) -> ParsedBeanInfo? {
    guard let info = try? JSONDecoder().decode(CoffeeBeanInfo.self, from: data) else { return nil }

    let name = normalizeOptional(info.name)
    let roaster = normalizeOptional(info.roaster)
    let origin = normalizeOptional(info.origin).flatMap { mapToOrigin($0) }
    let processing = normalizeOptional(info.processing).flatMap { mapToProcessing($0) }
    return ParsedBeanInfo(name: name?.isEmpty == true ? nil : name,
                          roaster: roaster,
                          origin: origin,
                          processing: processing)
}

private func mapToOrigin(_ value: String) -> Origin? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if let exact = Origin.allCases.first(where: { $0.rawValue == trimmed }) { return exact }
    if let ci = Origin.allCases.first(where: { $0.rawValue.compare(trimmed, options: .caseInsensitive) == .orderedSame }) { return ci }
    return nil
}

private func mapToProcessing(_ value: String) -> Processing? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if let exact = Processing.allCases.first(where: { $0.rawValue == trimmed }) { return exact }
    if let ci = Processing.allCases.first(where: { $0.rawValue.compare(trimmed, options: .caseInsensitive) == .orderedSame }) { return ci }
    return nil
}

private func normalizeOptional(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    let lower = trimmed.lowercased()
    let nullish: Set<String> = ["null", "none", "n/a", "na", "not set", "unknown", ":null", ":null,", ",", ":", "/", "/null", ":null}", "}", "null}"]
    if nullish.contains(lower) { return nil }
    return trimmed
}
