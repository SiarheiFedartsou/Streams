//
//  StreamAllMatchTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Streams
import Nimble

class StreamAllMatchTests: XCTestCase {
    
    func testThatAllMatchReturnsTrueIfAllElementsMatch() {
        // given
        let array = [12, 4, 3, 14, 10, 3, 4, 7]
        
        // when
        let result = array.stream.allMatch({ $0 < 15 })
        
        // then
        expect(result).to(beTrue())
    }
    
    func testThatAllMatchReturnsFalseIfAtLeastOneElementDoesntMatch() {
        // given
        let array = [12, 4, 17, 14, 10, 3, 4, 7]
        
        // when
        let result = array.stream.allMatch({ $0 < 15 })
        
        // then
        expect(result).to(beFalse())
    }
}
