//
//  ForEachStageTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Streams
import Nimble

class ForEachStageTests: XCTestCase {
    
    
    func testThatForEachWorksForEmptyStream() {
        // given
        let array = [Int]()
        
        // when
        var result = [Int]()
        array.stream
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([]))
    }
    
    func testThatForEachWorksForJustCreatedStream() {
        // given
        let array = [12, 4, 9, 14, 10, 3]
        
        // when
        var result = [Int]()
        array.stream
            .forEach({ result.append($0) })
        
        // then
        expect(result).to(equal([12, 4, 9, 14, 10, 3]))
    }
    
    func testThatForEachWorksForParallelStream() {
        // given
        var array = [Int]()
        for i in 0..<1000 {
            array.append(i % 10)
        }

        
        let queue = DispatchQueue(label: "org.streams_sync_queue")
        
        // when
        var result = [Int]()
        array.parallelStream
            .map {
                $0 * $0
            }.forEach { element in
                queue.sync {
                    result.append(element)
                }
        }
        
        // then
        expect(result.reduce(0, +)).to(equal(array.map { $0 * $0 }.reduce(0, +)))
    }
}
