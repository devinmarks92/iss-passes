//
//  iss_passesTests.swift
//  iss-passesTests
//
//  Created by Devin Marks on 2/28/18.
//  Copyright © 2018 Devin Marks All rights reserved.
//
import XCTest
@testable import iss_passes

class iss_passesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPassesAsArray() {
        let expect = XCTestExpectation()
        getPassesAsArray(latitude: 45, longitude: 45) { result in
            XCTAssertNotNil(result, "Result was nil")
            XCTAssert(result.count == 100, "Improper amount of results returned; is " + String(result.count) + ", should be 100")
            for obj in result {
                XCTAssert(obj.count == 2, "Improper amount of fields; is " + String(obj.count) + ", should be 2")
                XCTAssertNotNil(obj["risetime"], "Risetime not found")
                XCTAssertNotNil(obj["duration"], "Duration not found")
            }
            
            expect.fulfill()
        }
        wait(for: [expect], timeout: 10.0)
    }
    
    func testCurrentAsDictionary() {
        let expect = XCTestExpectation()
        getCurrentAsDictionary() { result in
            XCTAssertNotNil(result, "Result was nil")
            XCTAssert(result.count == 2, "Improper amount of fields; is " + String(result.count) + ", should be 2")
            XCTAssertNotNil(result["latitude"], "Latitude not found")
            XCTAssertNotNil(result["longitude"], "Longitude not found")
            
            expect.fulfill()
        }
        wait(for: [expect], timeout: 10.0)
    }
}
