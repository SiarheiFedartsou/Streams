//
//  StreamAnyMatchTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Streams
import Nimble

class StreamAnyMatchTests: XCTestCase {
    
    func testThatAnyMatchReturnsTrueIfAtLeastOneElementMatchesPredicate() {
        // given
        let array = [12, 4, 3, 14, 10, 3, 4, 7]
        
        // when
        let result = array.stream.anyMatch({ $0 > 12 })
        
        // then
        expect(result).to(beTrue())
    }
    
    func testThatAllMatchReturnsFalseIfNoElementMatchesPredicate() {
        // given
        let array = [12, 4, 17, 14, 10, 3, 4, 7]
        
        // when
        let result = array.stream.anyMatch({ $0 > 42 })
        
        // then
        expect(result).to(beFalse())
    }
}
