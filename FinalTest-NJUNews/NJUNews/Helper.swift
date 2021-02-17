//
//  Helper.swift
//  NJUNews
//
//  Created by zb-nju on 2021/1/27.
//

import NaturalLanguage

func getSearchTerms(text: String, language: String? = nil, block: (String) -> Void) {
    // To be replaced
    let pinyin = text
    let tagger = NLTagger(tagSchemes: [.lemma])
    tagger.string = pinyin
    if let language = language{
        tagger.setLanguage(NLLanguage(rawValue: language), range: pinyin.startIndex..<pinyin.endIndex)
    }
    let options: NLTagger.Options = [
    .omitWhitespace, .omitPunctuation, .omitOther, .joinNames]
    tagger.enumerateTags(in: pinyin.startIndex..<pinyin.endIndex, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
        let token = String(pinyin[tokenRange])
        if let tag = tag {
            let lemma = tag.rawValue
            block(lemma)
            if lemma != token {
                block(token)
            }
        }else{
            block(token)
        }
        return true
    }
}

extension String{
    func transformToPinYin()->String{
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        print(string)
        return string
    }
}
