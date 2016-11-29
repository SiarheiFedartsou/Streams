//
//  GeneratorsTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 29.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
import Streams

class GeneratorsTests: XCTestCase {
    
    func testThatGenerateWorks() {
        // when
        var lastFibonacci = 1
        var lastButOneFibonacci = 1
        
        var result = [Int]()
        result.append(lastFibonacci)
        result.append(lastButOneFibonacci)
        
        generate({
            let result = lastFibonacci + lastButOneFibonacci
            (lastFibonacci, lastButOneFibonacci) = (result, lastFibonacci)
            return result
        }).limit(7).forEach {
            result.append($0)
        }
        
        // then
        expect(result).to(equal([1, 1, 2, 3, 5, 8, 13, 21, 34]))
    }
    
    func testThatGenerateTerminatesStreamIfGeneratingClosureReturnsNil() {
        // when
        var previousValue = 0
        var result = [Int]()

        generate({
            previousValue += 1
            return previousValue < 5 ? previousValue : nil
        }).forEach {
            result.append($0)
        }
        
        // then
        expect(result).to(equal([1, 2, 3, 4]))
    }
    
    func testThatIterateWorks() {
        // when
        var result = [Int]()
        iterate(seed: 10) {
            $0 + 2
        }.limit(3).forEach {
            result.append($0)
        }

        
        // then
        expect(result).to(equal([10, 12, 14]))
    }
    
    func testThatIterateTerminatesStreamIfProducerReturnsNil() {
        // when
        var result = [Int]()
        iterate(seed: 10) {
            $0 < 18 ? $0 + 2 : nil
            }.forEach {
                result.append($0)
        }
        
        
        // then
        expect(result).to(equal([10, 12, 14, 16, 18]))
    }
    
}
