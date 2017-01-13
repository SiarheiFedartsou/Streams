//
//  RandomAccessCollectionSpliteratorTests.swift
//  Streams
//
//  Created by Sergey Fedortsov on 07.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import StreamsEx

class RandomAccessCollectionSpliteratorTests: XCTestCase {
    
    func testThatItProperlySplitsArray() {
        // given
        let array = (1...1024)
        
        // when
        var spliterator = RandomAccessCollectionSpliterator(collection: AnyRandomAccessCollection(array), options: StreamOptions())
        
        var newSpliterator = spliterator.split()
        
        // then
        expect(newSpliterator!.estimatedSize).to(equal(512))
        expect(spliterator.estimatedSize).to(equal(512))
        

        expect(newSpliterator!.advance()).to(equal(1))
        expect(newSpliterator!.advance()).to(equal(2))
        expect(newSpliterator!.advance()).to(equal(3))
        
        expect(spliterator.advance()).to(equal(513))
        expect(spliterator.advance()).to(equal(514))
        expect(spliterator.advance()).to(equal(515))
        
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
