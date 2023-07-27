//
//  BizCardAnnotateUseCase.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import RxSwift

struct BizCardAnnotateResult {
    let name: String?
    let comanyName: String?
    let tel: String?
    let email: String?
}

protocol BizCardAnnotateUseCaseInterface {
    func annotate(for: AnnotateImage) -> BizCardAnnotateResult
}

/// 名刺画像のOCR結果から名刺情報を抽出するUseCase
struct BizCardAnnotateUseCase: BizCardAnnotateUseCaseInterface {
    // 課題: 正規表現を変更して名刺要素を抽出する
    enum AnnotateTargetRegex: String {
        case name = "^\\p{Han}{1,3}\\s?\\p{Han}{1,3}$"
        case company = "株式会社"
        case tel = "TEL\\s?(\\d{2,3}-\\d{4}-\\d{4})"
        case email = "E-?mail\\s?([\\d\\.a-z\\-]+@[\\d\\.a-z]+)"
    }

    init() {}

    // 正規表現でOCRできた全文章から名刺情報を抽出する
    func annotate(for source: AnnotateImage) -> BizCardAnnotateResult {
        let texts = source.fullTextAnnotation?.text?.components(separatedBy: "\n")

        var name: String?
        var email: String?
        var tel: String?
        var company: String?

        texts?.forEach {
            let companyRegex = try! NSRegularExpression(pattern: AnnotateTargetRegex.company.rawValue)
            if let result = companyRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                company = ($0 as NSString).substring(with: result.range(at: 0))
            }

            let nameRegex = try! NSRegularExpression(pattern: AnnotateTargetRegex.name.rawValue)
            if let result = nameRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                name = ($0 as NSString).substring(with: result.range(at: 0))
            }

            let telRegex = try! NSRegularExpression(pattern: AnnotateTargetRegex.tel.rawValue)
            if let result = telRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                tel = ($0 as NSString).substring(with: result.range(at: 1))
            }

            let emailRegex = try! NSRegularExpression(pattern: AnnotateTargetRegex.email.rawValue)
            if let result = emailRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                email = ($0 as NSString).substring(with: result.range(at: 1))
            }
        }

        return .init(name: name, comanyName: company, tel: tel, email: email)
    }
}
