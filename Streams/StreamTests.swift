//
//  StreamTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
import Streams

class StreamTests: XCTestCase {

    
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
    
    func testThatLimitAfterSkipWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3, 4, 7]
        
        // when
        var result = [Int]()
        array.stream
            .skip(3)
            .limit(3)
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

    
    func testThatDefaultSortedWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3, 4, 7]
        
        // when
        var result = [Int]()
        array.stream
            .sorted()
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([3, 4, 4, 7, 9, 10, 12, 14]))
    }

    func testThatSortedWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3, 4, 7]
        
        // when
        var result = [Int]()
        array.stream
            .sorted(by: >)
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([14, 12, 10, 9, 7, 4, 4, 3]))
    }
    
    func testThatDistinctdWorks() {
        // given
        let array = [12, 4, 3, 14, 10, 3, 4, 7]
        
        // when
        var result = [Int]()
        array.stream
            .distinct()
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([12, 4, 3, 14, 10, 7]))
    }
    
    func testThatConcatWorks() {
        // given
        let array1 = [12, 4, 3, 14, 10, 3, 4, 7]
        let array2 = [3, 4, 2, 3]
        
        // when
        var result = [Int]()
        (array1.stream.distinct() + array2.stream.limit(3)).forEach { result.append($0) }
        
        // then
        expect(result).to(equal([12, 4, 3, 14, 10, 7, 3, 4, 2]))
    }
    
    func testThatConcatWorksForUnprocessedStreams() {
        // given
        let array1 = [12, 4, 3]
        let array2 = [3, 4, 2, 3]
        
        // when
        var result = [Int]()
        (array1.stream + array2.stream).forEach { result.append($0) }
        
        // then
        expect(result).to(equal([12, 4, 3, 3, 4, 2, 3]))
    }
}
