//
//  StreamMinTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 29.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Streams
import Nimble

class StreamMinTests: XCTestCase {
    
    func testThatMinReturnsMinimumValueAmongArrayOfInts() {
        // given
        let array = [12, 4, 3, 14, 10, 3, 4, 7]
        
        // when
        let result = array.stream.min()
        
        // then
        expect(result).to(equal(3))
    }
    
    func testThatCustomComparatorWorks() {
        // given
        let array = [14, 7, 9, 14, 23, 38, 4, 7]
        
        // when
        let result = array.stream.min(by: {
            return $0 % 10 > $1 % 10
        })
        
        // then
        expect(result).to(equal(23))
    }
    
    
}
