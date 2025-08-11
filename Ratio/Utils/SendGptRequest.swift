//
//  SendGptRequest.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 11..
//

import Foundation

// MARK: - Responses API request models

struct ResponsesRequest: Codable {
    let model: String
    let input: String
    let temperature: Int
    let text: TextOptions?
}

struct TextOptions: Codable {
    let format: TextFormatOptions?
}

struct TextFormatOptions: Codable {
    let type: String // "json_object" | "json_schema"
    let name: String?
    let schema: JSONSchemaRoot?
    let strict: Bool?
}

// Envelope removed; schema is now provided directly under text.schema

struct JSONSchemaRoot: Codable {
    let type: String
    let properties: [String: JSONSchemaProperty]
    let required: [String]
    let additionalProperties: Bool

    enum CodingKeys: String, CodingKey {
        case type
        case properties
        case required
        case additionalProperties
    }
}

struct JSONSchemaProperty: Codable {
    let type: String
    let nullable: Bool?
    let description: String?
}

// MARK: - Request function

func sendGptRequest(prompt: String, completion: @escaping (String?) -> Void) {
    let apiKey = "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"

    let url = URL(string: "https://api.openai.com/v1/responses")!

    // Compose a single input string suitable for the Responses API
    let instruction = "You are a parser. Given OCR text from a coffee bean bag label, extract: name, roaster, origin, processing. Return ONLY a JSON object with exactly these keys. Use null for missing values. If the text is not a coffee bean bag label, set all values to null."
    let input = instruction + "\n\nOCR TEXT:\n" + prompt

    // Define strict JSON schema
    let schema = JSONSchemaRoot(
        type: "object",
        properties: [
            "name": JSONSchemaProperty(type: "string", nullable: true, description: "Name of the coffee"),
            "roaster": JSONSchemaProperty(type: "string", nullable: true, description: "Roaster name"),
            "origin": JSONSchemaProperty(type: "string", nullable: true, description: "Origin country or region"),
            "processing": JSONSchemaProperty(type: "string", nullable: true, description: "Processing method of the raw coffee"),
        ],
        required: ["name", "roaster", "origin", "processing"],
        additionalProperties: false
    )

    let textOptions = TextOptions(
        format: TextFormatOptions(
            type: "json_schema",
            name: "CoffeeBeanInfo",
            schema: schema,
            strict: true
        )
    )

    // Prepare request body
    let requestBody = ResponsesRequest(
        model: "gpt-4o-mini",
        input: input,
        temperature: 1,
        text: textOptions
    )
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(requestBody)
        request.httpBody = jsonData
    } catch {
        print("Failed to encode request: \(error)")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request error: \(error)")
            DispatchQueue.main.async { completion(nil) }
            return
        }
        guard let data = data else {
            print("No data in response")
            DispatchQueue.main.async { completion(nil) }
            return
        }

        // Responses API: parse output content; prefer output_json, fallback to output_text
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

                // 1) Try to find structured JSON
                for content in contentsList {
                    if let jsonItem = content.first(where: { ($0["type"] as? String) == "output_json" }),
                       let jsonDict = jsonItem["json"] {
                        if JSONSerialization.isValidJSONObject(jsonDict) {
                            let compactData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                            let compactString = String(data: compactData, encoding: .utf8)
                            DispatchQueue.main.async { completion(compactString) }
                            return
                        }
                    }
                }

                // 2) Fallback to text; if it looks like JSON, return the JSON only
                for content in contentsList {
                    if let textItem = content.first(where: { ($0["type"] as? String) == "output_text" }),
                       let text = textItem["text"] as? String {
                        if let textData = text.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: textData, options: []),
                           JSONSerialization.isValidJSONObject(json) {
                            let compactData = try JSONSerialization.data(withJSONObject: json, options: [])
                            let compactString = String(data: compactData, encoding: .utf8)
                            DispatchQueue.main.async { completion(compactString) }
                        } else {
                            DispatchQueue.main.async { completion(text) }
                        }
                        return
                    }
                }
            }

            // Last resort: return raw string
            let raw = String(data: data, encoding: .utf8)
            DispatchQueue.main.async { completion(raw) }
        } catch {
            print("Failed to parse Responses API: \(error)")
            let raw = String(data: data, encoding: .utf8)
            DispatchQueue.main.async { completion(raw) }
        }
    }
    task.resume()
}

