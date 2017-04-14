//
//  ILPDFKitTests.swift
//  ILPDFKitTests
//
//  Created by Derek Blair on 2016-07-24.
//
//

import Quick
import Nimble
import ILPDFKit

class ILPDFKitTests: QuickSpec {
    
    override func spec() {
        describe("PDF Parsing") {
            context("dictionaries") {
                it("parses dictionaries") {
                    let source : String = "<< /A 42.5\n/B 77 >>"
                    let dict = ILPDFDictionary(representation: source)
                    expect(dict["A" as NSString] as? Float) == 42.5
                    expect(dict["B" as NSString] as? Int) == 77
                }
            }
        }
    }
    
}
