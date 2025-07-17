//
//  RelationshipParser.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import Foundation

class RelationshipParser: NSObject, XMLParserDelegate {
    private var relationships: [(id: String, type: String, target: String)] = []
    
    func parseRelationships(from xmlData: Data) -> [(id: String, type: String, target: String)] {
        relationships = []
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        parser.parse()
        return relationships
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "Relationship" {
            if let id = attributeDict["Id"],
               let type = attributeDict["Type"],
               let target = attributeDict["Target"] {
                relationships.append((id: id, type: type, target: target))
            }
        }
    }
}
