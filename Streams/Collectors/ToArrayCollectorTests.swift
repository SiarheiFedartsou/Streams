//
//  ToArrayCollectorTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 04.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
import Streams

class ToArrayCollectorTests: XCTestCase {
    
    func testThatToArrayCollectorCollectsElementsToArray() {
        // given
        let array = [12, 4, 3, 14, 10, 3, 4, 7]
        
        // when
        let result = array.stream.collect(toArray())
        
        // then
        expect(result).to(equal([12, 4, 3, 14, 10, 3, 4, 7]))
    }
    
}
