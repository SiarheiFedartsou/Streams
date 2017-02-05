//
//  DistinctBenchmarks.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 31.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import XCTest
@testable import StreamsEx
import Nimble

class DistinctBenchmarks: XCTestCase {

    
    func testSequential() {
        var array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        for _ in 1..<12 {
            array.append(contentsOf: array)
        }
        
        var sum: Int = 0
        self.measure {
            sum = array.stream/*.map {
                usleep(1)
                return $0
            }*/.distinct().reduce(identity: 0, accumulator: +)
        }
        
        expect(sum).to(equal(55))
    }
    
    
    func testParallel() {
        var array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        for _ in 1..<12 {
            array.append(contentsOf: array)
        }
        
        var sum: Int = 0
        self.measure {
            sum = array.parallelStream/*.map {
                usleep(1)
                return $0
            }*/.distinct().reduce(identity: 0, accumulator: +)
        }
        
        expect(sum).to(equal(55))
    }
    
    
}
