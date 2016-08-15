//
//  JsonParserTests.swift
//  JsonSerializer
//
//  Created by Fuji Goro on 2014/09/08.
//  Copyright (c) 2014 Fuji Goro. All rights reserved.
//

import XCTest

class JsonDeserializerTests: XCTestCase {

    func testEmptyArray() {
        let json = try! Json.deserialize("[]")
        XCTAssertEqual(json.description, "[]")
    }

    func testEmptyArrayWithSpaces() {
        let json = try! Json.deserialize(" [ ] ")
        XCTAssertEqual(json.description, "[]")
    }

    func testArray() {
        let json = try! Json.deserialize("[true,false,null]")
        XCTAssertEqual(json.description, "[true,false,null]")
    }

    func testArrayWithSpaces() {
        let json = try! Json.deserialize("[ true ,     false , null ]")
        XCTAssertEqual(json.description, "[true,false,null]")
    }

    func testEmptyObject() {
        let json = try! Json.deserialize("{}")
        XCTAssertEqual(json.description, "{}")
    }

    func testEmptyObjectWithSpace() {
        let json = try! Json.deserialize(" { } ")
        XCTAssertEqual(json.description, "{}")
    }

    func testObject() {
        let json = try! Json.deserialize("{\"foo\":[\"bar\",\"baz\"]}")
        XCTAssertEqual(json.description, "{\"foo\":[\"bar\",\"baz\"]}")
    }

    func testObjectWithWhiteSpaces() {
        let json = try! Json.deserialize(" { \"foo\" : [ \"bar\" , \"baz\" ] } ")
        XCTAssertEqual(json.description, "{\"foo\":[\"bar\",\"baz\"]}")
    }


    func testString() {
        let json = try! Json.deserialize("[\"foo [\\t] [\\r] [\\n]] [\\\\] bar\"]")
        XCTAssertEqual(json.description, "[\"foo [\\t] [\\r] [\\n]] [\\\\] bar\"]")
    }

    func testStringWithMyltiBytes() {
        let json = try! Json.deserialize("[\"こんにちは\"]")
        XCTAssertEqual(json[0]!.stringValue, "こんにちは")
        XCTAssertEqual(json.description, "[\"こんにちは\"]")
    }

    func testStringWithMyltiUnicodeScalars() {
        let json = try! Json.deserialize("[\"江戸前🍣\"]")
        XCTAssertEqual(json[0]!.stringValue!, "江戸前🍣")
        XCTAssertEqual(json[0]!.description, "\"江戸前🍣\"")
        XCTAssertEqual(json.description, "[\"江戸前🍣\"]")
    }

    func testNumberOfInt() {
        let json = try! Json.deserialize("[0, 10, 234]")
        XCTAssertEqual(json.description, "[0,10,234]")
    }

    func testNumberOfFloat() {
        let json = try! Json.deserialize("[3.14, 0.035]")
        XCTAssertEqual(json.description, "[3.14,0.035]")
    }

    func testNumberOfExponent() {
        let json = try! Json.deserialize("[1e2, 1e-2, 3.14e+01]")
        XCTAssertEqual(json[0]!.intValue, 100)
        XCTAssertEqual(json[1]!.doubleValue, 0.01)
        XCTAssertEqual("\(json[2]!.doubleValue!)", "31.4")
    }

    func testUnicodeEscapeSequences() {
        let json = try! Json.deserialize("[\"\\u003c \\u003e\"]")
        XCTAssertEqual(json[0]!.stringValue!, "< >")
    }

    func testUnicodeEscapeSequencesWith32bitsUnicodeScalar() {
        let json = try! Json.deserialize("[\"\\u0001\\uF363\"]")
        XCTAssertEqual(json[0]!.stringValue, "\u{0001F363}")
    }
    
    func testUnicodeEscapeSequencesWithTwo16bitsUnicodeScalar() {
        let json = try! Json.deserialize("[\"\\u00015\\uF363\"]")
        XCTAssertEqual(json[0]!.stringValue, "\u{0001}5\u{F363}")
    }

    func testTwitterJson() {
        let json = try! Json.deserialize(complexJsonExample(name: "tweets"))
        XCTAssertEqual(json["statuses"]![0]!["id_str"]!.stringValue, "250075927172759552")
    }

    func testStackexchangeJson() {
        let json = try! Json.deserialize(complexJsonExample(name: "stackoverflow-items"))
        XCTAssertEqual(json["items"]![0]!["view_count"]!.intValue, 18711)
    }


    func testPerformanceExampleWithNSData() {
        let jsonSource = complexJsonExample(name: "tweets")

        self.measure {
            let _ = try! Json.deserialize(jsonSource)
        }
    }

    func testPerformanceExampleWithString() {
        let jsonSource = String(data: complexJsonExample(name: "tweets") as Data, encoding: String.Encoding.utf8)!

        self.measure {
            let _ = try! Json.deserialize(jsonSource)
        }
    }

    func testPerformanceExampleInJSONSerialization() {
        let jsonSource = complexJsonExample(name: "tweets")
        self.measure {
            let _: AnyObject? = try! JSONSerialization
                .jsonObject(with: jsonSource as Data, options: .mutableContainers)
        }
    }

    func complexJsonExample(name: String) -> Data {
        let bundle = Bundle(for: self.dynamicType)
        let url = bundle.url(forResource: name, withExtension: "json")!
        do {
            return try Data(contentsOf: url)
        } catch {

        }
        return Data()
    }
}
