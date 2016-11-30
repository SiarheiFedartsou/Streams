//
//  StreamFlattenTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 30.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Streams
import Nimble

class StreamFlattenTests: XCTestCase {
    
    func testThatFlattenMethodFlattensStreamOfStreams() {
        // given
        let array = [2, 1, 3]
        
        // when
        var result = [Int]()
        array.stream
            .map { (0...$0).stream }
            .flatten()
            .forEach { result.append($0) }
        
        // then
        expect(result).to(equal([0, 1, 2, 0, 1, 0, 1, 2, 3]))
    }
    
    func testThatFlatMapWorks() {
        // given
        let array = [2, 1, 3]
        
        // when
        var result = [Int]()
        array.stream
            .flatMap { (0...$0).stream }
            .forEach { result.append($0) }
        
        // then
        expect(result).to(equal([0, 1, 2, 0, 1, 0, 1, 2, 3]))
    }
}
