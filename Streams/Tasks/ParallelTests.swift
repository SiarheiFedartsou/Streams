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


class ParallelTests: XCTestCase {
    
    
    func testStreamsPerfomance() {
        var testCollection = [Int]()
        for i in 0..<100_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
         //   var result = 0
            
            let spliterator = RandomAccessCollectionSpliterator(collection: testCollection, options: StreamOptions())
            let task = ReduceTask(spliterator: AnySpliterator(spliterator), accumulator: +)
            let result = task.invoke()
//            while let element = spliterator.advance() {
//                result += element
//            }
            expect(result).to(equal(450000))
        }
    }
    
    func testStdlibReducePerfomance() {
        var testCollection = [Int]()
        for i in 0..<100_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
            let result = testCollection.reduce(0, +)
            expect(result).to(equal(450000))
        }
    }
    
    
    func testClassicPerfomance() {
        var testCollection = [Int]()
        for i in 0..<100_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
            var result = 0
            
            var iterator = testCollection.makeIterator()
            while let element = iterator.next() {
                result += element
            }
            expect(result).to(equal(450000))
        }
    }
    
}
