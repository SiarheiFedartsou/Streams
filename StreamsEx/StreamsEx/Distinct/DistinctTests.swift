//
//  DistinctTests.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 27.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import StreamsEx

class DistinctTests: XCTestCase {
    
    func testThatSequentialDistinctWorksForDistinctCollection() {
        // given
        let set = Set([42, 41, 40])
        
        
        // when
        let sum = set.stream.distinct().reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(123))
    }
    
    func testThatParallelDistinctWorksForDistinctCollection() {
        // given
        let set = Set([42, 41, 40])
        
        
        // when
        let sum = set.parallelStream.distinct().reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(123))
    }
    
    func testThatSequentialDistinctWorksForOrderedCollection() {
        // given
        let array = [42, 41, 40]
        
        
        // when
        let sum = array.stream.distinct().reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(123))
    }
    
    func testThatParallelDistinctWorksForOrderedCollection() {
        // given
        let array = [42, 41, 40]
        
        
        // when
        let sum = array.parallelStream.distinct().reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(123))
    }
    
    func testThatSequentialDistinctWorksForUnorderedCollection() {
        // given
        let array = [42, 41, 40]
        
        
        // when
        let sum = array.stream.unordered().distinct().reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(123))
    }
    
    func testThatParallelDistinctWorksForUnorderedCollection() {
        // given
        let array = [42, 41, 40]
        
        
        // when
        let sum = array.parallelStream.unordered().distinct().reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(123))
    }
    
}
