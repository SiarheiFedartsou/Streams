//
//  OrderedTests.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 20.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import XCTest
import Nimble
@testable import StreamsEx


class OrderedTests: XCTestCase {
    func testThatIsOrderedReturnsTrueIfSourceCollectionWasOrdered() {
        // given
        let array = [42, 41, 40]
        
        // then
        expect(array.stream.isOrdered).to(beTrue())
    }
    
    func testThatIsOrderedReturnsFalseIfSourceCollectionWasUnordered() {
        // given
        let set = Set([42, 41, 40])
        
        // then
        expect(set.stream.isOrdered).to(beFalse())
    }
    
    func testThatUnorderedReturnsUnorderedStreamIfSourceCollectionWasOrdered() {
        // given
        let array = [42, 41, 40]
        
        // when
        let stream = array.stream.unordered()
        
        // then
        expect(stream.isOrdered).to(beFalse())
    }
    
    func testThatUnorderedReturnsUnorderedStreamIfSourceCollectionWasUnordered() {
        // given
        let set = Set([42, 41, 40])
        
        // when
        let stream = set.stream.unordered()
        
        // then
        expect(stream.isOrdered).to(beFalse())
    }
    
}
