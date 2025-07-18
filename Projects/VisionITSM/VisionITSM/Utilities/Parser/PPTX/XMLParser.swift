//
//  XMLParser.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import Foundation

class SimpleXMLParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var foundText = ""
    private var extractedText = ""
    private var isInTextElement = false
    
    func extractNotesContent(from xmlString: String) -> String {
        guard let data = xmlString.data(using: .utf8) else { return "" }
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        extractedText = ""
        parser.parse()
        
        print("추출된 텍스트 : \(extractedText)")
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "a:t" || elementName == "t" {
            isInTextElement = true
            foundText = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInTextElement {
            foundText += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "a:t" || elementName == "t" {
            isInTextElement = false
            if !foundText.isEmpty {
                extractedText += foundText + " "
            }
        }
    }
}
