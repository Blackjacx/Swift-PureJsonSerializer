//
//  JsonSerializer/JsonSerializerTests.swift
//
//  Created by Fuji Goro on 2014/09/08.
//  Copyright (c) 2014 Fuji Goro. All rights reserved.
//

import XCTest

class JsonletTests: XCTestCase {

    func testEmptyArray() {
        let x = JsonParser.parse(" [ ] ")

        switch x {
        case .Success(let json, _):
            XCTAssertEqual(json.description, "[]")
        case .Error(let error, let parser):
            XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
        }
    }


    func testArray() {
        let x = JsonParser.parse("[\"foo bar\", true, false]")

        switch x {
        case .Success(let json, _):
            XCTAssertEqual(json.description, "[\"foo bar\",true,false]")
        case .Error(let error, let parser):
            XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
        }
    }

    func testEmptyObject() {
        let x = JsonParser.parse(" { } ")

        switch x {
        case .Success(let json, _):
            XCTAssertEqual(json.description, "{}")
        case .Error(let error, let parser):
            XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
        }
    }

    func testString() {
        let x = JsonParser.parse("[\"foo [\\t] [\\r] [\\n]] [\\\\] bar\"]")

        switch x {
        case .Success(let json, _):
            XCTAssertEqual(json.description, "[\"foo [\\t] [\\r] [\\n]] [\\\\] bar\"]")
        case .Error(let error, let parser):
            XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
        }
    }

    func testNumber() {
        let x = JsonParser.parse("[10, 3.14]")

        switch x {
        case .Success(let json, _):
            XCTAssertEqual(json.description, "[10,3.14]")
        case .Error(let error, let parser):
            XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
        }
    }

    func testJsonValue() {
        let x = JsonParser.parse("[\"foo bar\", true, false]")

        switch x {
        case .Success(let json, _):
            XCTAssertEqual(json.description, "[\"foo bar\",true,false]")

            XCTAssertEqual(json[0].stringValue, "foo bar")
            XCTAssertEqual(json[1].boolValue, true)
            XCTAssertEqual(json[2].boolValue, false)

            XCTAssertEqual(json[3].stringValue, "", "out of range")

            XCTAssertEqual(json["no"]["suck"]["value"].stringValue, "", "no such properties")
        case .Error(let error, let parser):
            XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
        }
    }

    func testComplexJson() {
        let x = JsonParser.parse(complexJsonExample())
        switch x {
        case .Success(let json, _):
            XCTAssertEqual(json["statuses"][0]["id_str"].stringValue, "250075927172759552")

        case .Error(let error, let parser):
            XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
        }
    }

    func testPerformanceExample() {
        let jsonSource = complexJsonExample()

        self.measureBlock {
            switch JsonParser(jsonSource).parse() {
            case .Success(let json, _):
                XCTAssertTrue(true)
            case .Error(let error, let parser):
                XCTFail("\(error.reason) at line \(parser.lineNumber) column \(parser.columnNumber)")
            }
        }
    }

    func testPerformanceExampleInJSONSerialization() {
        let jsonSource = complexJsonExample().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        self.measureBlock {
            var error: NSError? = nil
            let dict: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonSource!, options: .MutableContainers, error: &error)

            switch error {
            case .None:
                break
            case .Some(let e):
                XCTFail("error: \(e)")
            }
        }
    }

    func complexJsonExample() -> String {
        let bundle = NSBundle(forClass: JsonletTests.self)
        let path = bundle.pathForResource("tweets", ofType: "json")!
        return NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
    }
}