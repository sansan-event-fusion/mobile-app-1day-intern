//
//  BizCardFactoryUseCase.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/12.
//

import Foundation

protocol BizCardFactoryUseCaseInterface {
    func createBizCard(from annotateImage: AnnotateImage) -> BizCard
}

final class BizCardFactoryUseCase: BizCardFactoryUseCaseInterface {
    // 名刺要素を抽出する
    enum AnnotateTargetRegex: String {
        case name = "^\\p{Han}{1,3}\\s?\\p{Han}{1,3}$"
        // ~~株式会社、~~会社、株式会社~~、
        case company = "([一-龥ぁ-んァ-ヶーa-zA-Z0-9ａ-ｚＡ-Ｚ０-９]+(株式会社|有限会社|合資会社|合名会社|合同会社))|((株式会社|有限会社|合資会社|合名会社|合同会社)[一-龥ぁ-んァ-ヶーa-zA-Z0-9ａ-ｚＡ-Ｚ０-９]+)|(\\w+(\\s\\w+)*(,\\s(?:Inc|Ltd|LLC|Corp|Incorporated|Limited|Corporation|Company)\\.?)|(\\w+(\\s\\w+)*(?:Inc|Ltd|LLC|Corp|Incorporated|Limited|Corporation|Company)))"
        case tel = "TEL\\s?(\\d{2,3}-\\d{4}-\\d{4})"
        case email = "E-?mail\\s?([\\d\\.a-z\\-]+@[\\d\\.a-z]+)"
    }

    init() {}

    // 正規表現でOCRできた全文章から名刺情報を抽出する
    func createBizCard(from source: AnnotateImage) -> BizCard {
        let texts = source.fullTextAnnotation?.text?.components(separatedBy: "\n")

        var name: String?
        var email: String?
        var tel: String?
        var company: String?

        texts?.forEach {
            let companyRegex = try? NSRegularExpression(pattern: AnnotateTargetRegex.company.rawValue)
            if let result = companyRegex?.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                company = ($0 as NSString).substring(with: result.range(at: 0))
            }

            let nameRegex = try? NSRegularExpression(pattern: AnnotateTargetRegex.name.rawValue)
            if let result = nameRegex?.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                name = ($0 as NSString).substring(with: result.range(at: 0))
            }

            let telRegex = try? NSRegularExpression(pattern: AnnotateTargetRegex.tel.rawValue)
            if let result = telRegex?.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                tel = ($0 as NSString).substring(with: result.range(at: 1))
            }

            let emailRegex = try? NSRegularExpression(pattern: AnnotateTargetRegex.email.rawValue)
            if let result = emailRegex?.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                email = ($0 as NSString).substring(with: result.range(at: 1))
            }
        }

        return .init(
            id: .init(rawValue: UUID().uuidString),
            name: name,
            companyName: company,
            tel: tel,
            email: email,
            createdAt: .init()
        )
    }
}
