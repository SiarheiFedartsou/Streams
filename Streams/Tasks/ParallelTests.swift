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
        for i in 0..<10_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
            let spliterator = RandomAccessCollectionSpliterator(collection: testCollection, options: StreamOptions())
            let task = ReduceTask(spliterator: AnySpliterator(spliterator), accumulator: {
                usleep(1)
                return $0 + $1
            })
            let result = task.invoke()
            expect(result).to(equal(45_000))
        }
    }
    
    func testStdlibReducePerfomance() {
        var testCollection = [Int]()
        for i in 0..<10_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
            let result = testCollection.reduce(0, {
                usleep(1)
                return $0 + $1
            })
            expect(result).to(equal(45_000))
        }
    }
    
    
    func testClassicPerfomance() {
        var testCollection = [Int]()
        for i in 0..<10_000 {
            testCollection.append(i % 10)
        }
        
        
        self.measure {
            var result = 0
            
            var iterator = testCollection.makeIterator()
            while let element = iterator.next() {
                usleep(1)
                result += element
            }
            expect(result).to(equal(45_000))
        }
    }
    
}
