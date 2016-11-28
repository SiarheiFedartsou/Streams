//
//  StreamCountTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
import Streams

class StreamCountTests: XCTestCase {
    
    func testThatCountWorksForJustCreatedStream() {
        // given
        let array = [12, 4, 3, 14, 10]
        
        // when
        let count = array.stream.count
        
        // then
        expect(count).to(equal(5))
    }
    
    func testThatCountWorksForFilteredStream() {
        // given
        let array = [12, 4, 3, 14, 10]
        
        // when
        let count = array.stream.filter({ $0 >= 10 }).count
        
        // then
        expect(count).to(equal(3))
    }
    
    
}
