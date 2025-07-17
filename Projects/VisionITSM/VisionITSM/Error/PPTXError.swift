//
//  PPTXError.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import Foundation

enum PPTXError: Error, LocalizedError {
    case invalidArchive
    case fileNotFound
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .invalidArchive:
            return "유효하지 않은 PPTX 파일입니다."
        case .fileNotFound:
            return "파일을 찾을 수 없습니다."
        case .parsingError:
            return "파일 파싱 중 오류가 발생했습니다."
        }
    }
}
