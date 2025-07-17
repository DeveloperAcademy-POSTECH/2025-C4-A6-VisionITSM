//
//  NotesMappingParser.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import Foundation
import ZIPFoundation

class notesMappingParser {
    func extractNotesWithPreciseMapping(from pptxURL: URL) throws -> [SlideNoteMapping] {
        let archive: Archive
        
        do {
            archive = try Archive(url: pptxURL, accessMode: .read)
        } catch {
            throw PPTXError.invalidArchive
        }
        
        // 1. 슬라이드-노트 관계 매핑 테이블 생성
        let slideToNotesMap = try createSlideNotesMapping(archive: archive)
        
        // 2. 모든 슬라이드 파일 찾기
        let slideEntries = archive.filter { entry in
            entry.path.contains("ppt/slides/slide") &&
            entry.path.hasSuffix(".xml") &&
            !entry.path.contains("_rels")
        }.sorted { entry1, entry2 in
            let num1 = extractSlideNumber(from: entry1.path)
            let num2 = extractSlideNumber(from: entry2.path)
            return num1 < num2
        }
        
        var mappings: [SlideNoteMapping] = []
        
        // 3. 모든 슬라이드에 대해 처리
        for entry in slideEntries {
            let slideNumber = extractSlideNumber(from: entry.path)
            
            if let notesFileName = slideToNotesMap[slideNumber] {
                // 해당 슬라이드에 발표자 메모가 있는 경우
                let noteText = try extractNoteText(from: notesFileName, archive: archive)
                mappings.append(SlideNoteMapping(
                    slideNumber: slideNumber,
                    notesFileName: notesFileName,
                    noteText: noteText,
                    hasNotes: true
                ))
                print("슬라이드 \(slideNumber): 발표자 메모 있음 - \(notesFileName)")
            } else {
                // 발표자 메모가 없는 경우
                mappings.append(SlideNoteMapping(
                    slideNumber: slideNumber,
                    notesFileName: nil,
                    noteText: "",
                    hasNotes: false
                ))
                print("슬라이드 \(slideNumber): 발표자 메모 없음")
            }
        }
        
        print("총 \(mappings.count)개 슬라이드 매핑 완료")
        return mappings
    }
    
    private func createSlideNotesMapping(archive: Archive) throws -> [Int: String] {
        var slideToNotesMapping: [Int: String] = [:]
        
        // 모든 슬라이드 관계 파일 검색
        let slideRelEntries = archive.filter { entry in
            entry.path.contains("ppt/slides/_rels/slide") &&
            entry.path.hasSuffix(".xml.rels")
        }
        
        for entry in slideRelEntries {
            // 슬라이드 번호 추출 (slide3.xml.rels → 3)
            let slideNumber = extractSlideNumber(from: entry.path)
            
            // 관계 파일에서 notesSlide 참조 찾기
            _ = try? archive.extract(entry) { data in
                if let xmlString = String(data: data, encoding: .utf8) {
                    if let notesSlideTarget = extractNotesSlideTarget(from: xmlString) {
                        slideToNotesMapping[slideNumber] = notesSlideTarget
                        print("관계 매핑: 슬라이드 \(slideNumber) → \(notesSlideTarget)")
                    }
                }
            }
        }
        
        return slideToNotesMapping
    }
    
    private func extractNotesSlideTarget(from xmlString: String) -> String? {
        let relationshipParser = RelationshipParser()
        guard let data = xmlString.data(using: .utf8) else { return nil }
        
        let relationships = relationshipParser.parseRelationships(from: data)
        
        for relationship in relationships {
            if relationship.type.contains("notesSlide") {
                // "../notesSlides/notesSlide1.xml" → "notesSlide1.xml"
                let fileName = (relationship.target as NSString).lastPathComponent
                return fileName
            }
        }
        
        return nil
    }
    
    private func extractNoteText(from notesFileName: String, archive: Archive) throws -> String {
        let notesPath = "ppt/notesSlides/\(notesFileName)"
        
        guard let entry = archive.first(where: { $0.path == notesPath }) else {
            return ""
        }
        
        var noteText = ""
        _ = try? archive.extract(entry) { data in
            if let xmlString = String(data: data, encoding: .utf8) {
                noteText = self.extractTextFromNotesXML(xmlString)
            }
        }
        
        return noteText
    }
    
    private func extractSlideNumber(from path: String) -> Int {
        let fileName = (path as NSString).lastPathComponent
        let numbers = fileName.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers) ?? 0
    }
    
    private func extractTextFromNotesXML(_ xmlString: String) -> String {
        let parser = SimpleXMLParser()
        return parser.extractNotesContent(from: xmlString)
    }
}
