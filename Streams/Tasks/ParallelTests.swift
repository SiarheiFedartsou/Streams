//
//  ParallelTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 07.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
@testable import Streams
import Nimble

extension Int : Initializable {}

class ParallelTests: XCTestCase {
    
    
    func testStreamsPerfomance() {
        var testCollection = [Int]()
        for i in 0..<100_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
            let spliterator = RandomAccessCollectionSpliterator(collection: AnyRandomAccessCollection(testCollection), options: StreamOptions())
            let task = ReduceTask<Int>(spliterator: AnySpliterator(spliterator), accumulator: +)
            let result = task.invoke()
            expect(result).to(equal(450000))
        }
    }
    
    func testStdlibPerfomance() {
        var testCollection = [Int]()
        for i in 0..<100_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
            let result = testCollection.reduce(0, +)
            expect(result).to(equal(450000))
        }
    }
    
}
