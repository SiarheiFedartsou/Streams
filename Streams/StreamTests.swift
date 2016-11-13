//
//  StreamTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import Streams

class StreamTests: XCTestCase {
    
    func testThatFilterWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [Int]()
        array.stream.filter({ $0 < 10 }).forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([4, 9, 3]))
    }
    
    func testThatMapWorks() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [String]()
        array.stream.filter({ $0 < 10 }).map({ "\($0)" }).forEach({ result.append($0) })
        
        // then
        expect(result).to(equal(["4", "9", "3"]))
    }
    
}
