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
    
    func testThatDistinctWorksForInt() {
        // given
        let array = [42, 42, 42, 40]
        
        
        // when
        let sum = array.stream.distinct().reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(82))
    }
    
}
