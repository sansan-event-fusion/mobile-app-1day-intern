//
//  BizCardOCRUseCase.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/08.
//

import Foundation
import UIKit.UIImage

protocol BizCardOCRUseCaseInterface {
    func recognize(image: UIImage) async throws -> [AnnotateImage]
}

enum BizCardOCRUseCaseError: Error {
    case invalidImage
    case apiError

    var localizedDescription: String {
        switch self {
        case .invalidImage:
            return String(localized: "ocr_error_invalid_image")
        case .apiError:
            return String(localized: "ocr_error_api_error")
        }
    }
}

class BizCardOCRUseCase: BizCardOCRUseCaseInterface {
    let apiClient: APIClientInterface

    init(apiClient: APIClientInterface) {
        self.apiClient = apiClient
    }

    func recognize(image: UIImage) async throws -> [AnnotateImage] {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            throw BizCardOCRUseCaseError.invalidImage
        }
        let request = GoogleAPIRequest(imageData: imageData)
        do {
            return try await apiClient.send(request).responses
        } catch {
            if let apiError = error as? APIError {
                switch apiError {
                case .invalidResponse:
                    NSLog("Invalid response")
                case let .failureRequest(statusCode):
                    NSLog("Failure request: \(statusCode)")
                }
            } else {
                NSLog("Unknown error: \(error)")
            }
            throw BizCardOCRUseCaseError.apiError
        }
    }
}
