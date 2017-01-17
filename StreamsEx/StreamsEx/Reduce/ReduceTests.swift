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
    
}
