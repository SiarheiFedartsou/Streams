//
//  GroupingByCollectorTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 04.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
import Streams

class GroupingByCollectorTests: XCTestCase {
    
    func testThatToArrayCollectorCollectsElementsToArray() {
        // given
        let array = [12, 4, 3, 14, 10, 3, 4, 7]
        
        // when
        let result: [Int: [Int]] = array.stream.collect(grouping(by: { $0 % 10 }))
        
        
        
        // then
        let expectedResult = [
            0: [10],
            2: [12],
            3: [3, 3],
            4: [4, 14, 4],
            7: [7]
        ]
        
        for (key, value) in result {
            expect(value).to(equal(expectedResult[key]))
        }
    }
    
}
