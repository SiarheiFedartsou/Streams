//
//  SliceTests.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 15.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import StreamsEx

class SliceTests: XCTestCase {
    
    func testThatSliceWorks() {
        
        // given
        let array = [43, 42, 41, 40, 39, 20, 22]
        
        
        // when
        let sum = array.stream.slice(1...5).reduce(identity: 0, accumulator: +)
        
        // then
        expect(sum).to(equal(162))
    }
    
}
