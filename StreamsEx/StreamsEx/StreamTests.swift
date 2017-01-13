//
//  StreamTests.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import StreamsEx

class StreamTests: XCTestCase {
    
    func testThatItProperlyWrapsSink() {
        
        // given
        class TestSink : UntypedSinkProtocol {
            func begin(size: Int) {}
            func end() {}
            var cancellationRequested: Bool { return false }
            func consume(_ element: Any) {
                consumedElements.append(element as! Int)
            }
            
            var consumedElements: [Int] = []
        }
        
        let spliterator = RandomAccessCollectionSpliterator(collection: [Int](), options: StreamOptions())
        let stream = PipelineHead(source: AnySpliterator(spliterator), characteristics: StreamOptions(), parallel: false).map { $0 * $0 }.map { $0 + 1 }
        
        let testSink = TestSink()
        
        
        // when
        let wrappedSink = stream.wrap(sink: testSink)
        
        for n in 1...5 {
            wrappedSink.consume(n)
        }
        
        // then
        expect(testSink.consumedElements).to(equal([2, 5, 10, 17, 26]))
    }
    
}
