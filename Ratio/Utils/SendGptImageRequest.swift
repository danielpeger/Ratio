//
//  SendGptImageRequest.swift
//  Ratio
//
//  Created by Assistant on 2025. 08. 11..
//

import Foundation

/// Sends an image to the OpenAI Responses API (gpt-5-nano) and asks it to extract
/// structured fields from a coffee bean bag: name, roaster, origin, processing.
/// The completion returns a JSON string representing the strict object, or nil on failure.
func sendGptImageRequest(imageData: Data, completion: @escaping (String?) -> Void) {
    let apiKey = "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"

    guard let url = URL(string: "https://api.openai.com/v1/responses") else {
        completion(nil)
        return
    }

    let instruction = "You are a parser. Given an image of a coffee bean bag label, extract: name, roaster, origin, processing. Return ONLY a JSON object with exactly these keys. Use null for missing values. If the image is not a coffee bean bag label, set all values to null."

    // Build data URI for the image
    let mimeType = guessMimeType(for: imageData)
    let base64 = imageData.base64EncodedString()
    let dataURL = "data:\(mimeType);base64,\(base64)"

    // Strict JSON schema definition
    let schema: [String: Any] = [
        "type": "object",
        "properties": [
            "name": ["type": "string", "nullable": true, "description": "Name of the coffee"],
            "roaster": ["type": "string", "nullable": true, "description": "Roaster name"],
            "origin": ["type": "string", "nullable": true, "description": "Origin country or region"],
            "processing": ["type": "string", "nullable": true, "description": "Processing method of the raw coffee"]
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
        "reasoning": ["effort": "minimal"],
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

        // Parse just the structured JSON if present, else fallback like the text function
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
                        if JSONSerialization.isValidJSONObject(jsonDict) {
                            let compact = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                            let compactString = String(data: compact, encoding: .utf8)
                            DispatchQueue.main.async { completion(compactString) }
                            return
                        }
                    }
                }

                // Fallback to text; if it looks like JSON, return only the JSON part
                for content in contentsList {
                    if let textItem = content.first(where: { ($0["type"] as? String) == "output_text" }),
                       let text = textItem["text"] as? String {
                        if let textData = text.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: textData, options: []),
                           JSONSerialization.isValidJSONObject(json) {
                            let compact = try JSONSerialization.data(withJSONObject: json, options: [])
                            let compactString = String(data: compact, encoding: .utf8)
                            DispatchQueue.main.async { completion(compactString) }
                        } else {
                            DispatchQueue.main.async { completion(text) }
                        }
                        return
                    }
                }
            }

            // Last resort: return raw body
            let raw = String(data: data, encoding: .utf8)
            DispatchQueue.main.async { completion(raw) }
        } catch {
            print("sendGptImageRequest parse error: \(error)")
            let raw = String(data: data, encoding: .utf8)
            DispatchQueue.main.async { completion(raw) }
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