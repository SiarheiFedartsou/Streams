//
//  SliceBenchmarks.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 09.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import XCTest
@testable import StreamsEx
import Nimble

class SliceBenchmarks: XCTestCase {
    
    func testSequential() {
        // given
        let array = [Int](repeating: 42, count: 100_000)
        
        
        // when
        var sum = 0
        measure {
            sum = array.stream.slice(90000...91000).reduce(identity: 0, accumulator: +)
        }
        
        // then
        expect(sum).to(equal(42000))
    }
    
    
    func testParallel() {
        // given
        let array = [Int](repeating: 42, count: 100_000)
        
        
        // when
        var sum = 0
        measure {
            sum = array.parallelStream.slice(90000...91000).reduce(identity: 0, accumulator: +)
        }
        // then
        expect(sum).to(equal(42000))
    }
    
}
