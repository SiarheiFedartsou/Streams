//
//  ReduceTests.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 17.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble

class ReduceTests: XCTestCase {
    
    func testThatReduceWorksForParallelStreamsWithoutStatefulStages() {
        // given
        let array = [Int](repeating: 42, count: 1024)
        
        // when
        let sum = array.parallelStream
            .map { $0 * $0 }
            .map { $0 + 1 }
            .reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(1807360))
    }
    
//    func testThatReduceWorksForParallelStreamsWithStatefulStages() {
//        // given
//        let array = [Int](repeating: 42, count: 1024)
//        
//        // when
//        let sum = array.parallelStream
//            .distinct()
//            .map { $0 * $0 }
//            .map { $0 + 1 }
//            .reduce(identity: 0, accumulator: +)
//        
//        // then
//        expect(sum).to(equal(42 * 42 + 1))
//    }
    
    
    func testThatReduceWithCombinerWorksInParallelStreams() {
        
        // given
        let array = [Int](repeating: 42, count: 1024)
        
        // when
        let result = array.parallelStream
            .map { $0 * $0 }
            .reduce(identity: [Int](), accumulator: { (container, element) in
                var result = container
                result.append(element)
                return result
            }, combiner: { (containerA, containerB) in
                var result = containerA
                result.append(contentsOf: containerB)
                return result
            })
        
        // then
        expect(result).to(equal([Int](repeating: 42 * 42, count: 1024)))
    }
}
