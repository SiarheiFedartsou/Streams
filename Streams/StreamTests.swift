//
//  StreamTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import Streams

class StreamTests: XCTestCase {
    
    func testThatForEachWorksForJustCreatedStream() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [Int]()
        array.stream
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([12, 4, 9, 14, 10, 3]))
    }
    
    func testThatFilterWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [Int]()
        array.stream
            .filter({ $0 < 10 })
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([4, 9, 3]))
    }
    
    func testThatMapWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [String]()
        array.stream
            .filter({ $0 < 10 })
            .map({ "\($0)" })
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal(["4", "9", "3"]))
    }
    
    func testThatMapSequenceWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [String]()
        array.stream
            .filter({ $0 < 10 })
            .map({ $0 * 10 })
            .map({ "\($0)" })
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal(["40", "90", "30"]))
    }
    
    func testThatLimitWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [Int]()
        array.stream
            .limit(3)
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([12, 4, 9]))
    }
    
    func testThatSkipWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [Int]()
        array.stream
            .skip(3)
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([14, 10, 3]))
    }
    
    func testThatReduceWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        let result = array.stream.reduce(identity: 0, accumulator: +)
        
        // then
        expect(result).to(equal(52))
    }
    
}
