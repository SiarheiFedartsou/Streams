//
//  StreamSumTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
import Streams


class StreamSumTests: XCTestCase {
    
    func testThatSumWorksForIntegerElements() {
        // given
        let array = [11, 4, 3, 14, 10]
        
        // when
        let sum = array.stream.sum()
        
        // then
        expect(sum).to(equal(42))
    }
    
    func testThatSumWorksForFloatingPointElements() {
        // given
        let array = [11.5, 3.5, 3, 14, 10]
        
        // when
        let sum = array.stream.sum()
        
        // then
        expect(sum).to(equal(42.0))
    }
    
    
}
