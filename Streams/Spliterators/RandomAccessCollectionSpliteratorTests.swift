//
//  RandomAccessCollectionSpliteratorTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 07.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import Streams

class RandomAccessCollectionSpliteratorTests: XCTestCase {
    
    func testThatItProperlySplitsArray() {
        // given
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        // when
        var spliterator = RandomAccessCollectionSpliterator(collection: AnyRandomAccessCollection(array), options: StreamOptions())
        
        var newSpliterator = spliterator.split()
        
        // then
        expect(newSpliterator!.estimatedSize).to(equal(5))
        expect(spliterator.estimatedSize).to(equal(5))
        
        var originSpliteratorRemainingElements = [Int]()
        spliterator.forEachRemaining { originSpliteratorRemainingElements.append($0) }
        var newSpliteratorRemainingElements = [Int]()
        newSpliterator!.forEachRemaining { newSpliteratorRemainingElements.append($0) }
        
        
        expect(originSpliteratorRemainingElements).to(equal([6, 7, 8, 9, 10]))
        expect(newSpliteratorRemainingElements).to(equal([1, 2, 3, 4, 5]))
    }
    
    func testThatItDoesntSplitsIfThereIsNothingToSplit() {
        // given
        let array = [42]
        
        // when
        var spliterator = RandomAccessCollectionSpliterator(collection: AnyRandomAccessCollection(array), options: StreamOptions())
        
        let newSpliterator = spliterator.split()
        
        // then
        expect(newSpliterator).to(beNil())
        
        expect(spliterator.estimatedSize).to(equal(1))
        var originSpliteratorRemainingElements = [Int]()
        spliterator.forEachRemaining { originSpliteratorRemainingElements.append($0) }
        
        
        expect(originSpliteratorRemainingElements).to(equal([42]))
    }
}
