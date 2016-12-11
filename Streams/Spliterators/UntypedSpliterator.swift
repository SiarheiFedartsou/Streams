//
//  UntypedSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 11.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//


protocol UntypedSpliteratorProtocol {
    mutating func advance() -> Any?
    mutating func forEachRemaining(_ each: (Any) -> Void)
    mutating func split() -> UntypedSpliteratorProtocol?
    
    var options: StreamOptions { get }
    var estimatedSize: Int { get }
}

struct UntypedSpliterator<Spliterator: SpliteratorProtocol> : UntypedSpliteratorProtocol {
    private var spliterator: Spliterator
    
    init(_ spliterator: Spliterator) {
        self.spliterator = spliterator;
    }
    
    mutating func advance() -> Any? {
        return self.spliterator.advance()
    }
    
    mutating func forEachRemaining(_ each: (Any) -> Void) {
        self.spliterator.forEachRemaining(each)
    }
    
    mutating func split() -> UntypedSpliteratorProtocol? {
        guard let splitted = self.spliterator.split() else { return nil }
        
        // TODO: 
        // for the first look it should work without any casting,
        // but currently in Swift 3.0.1 we have strange error `AnySpliterator<Spliterator.T> is not convertible to Spliterator`
        // hope it will be fixed in the next versions
        return UntypedSpliterator(splitted as! Spliterator)
    }
    
    var options: StreamOptions {
        return self.spliterator.options
    }
    
    var estimatedSize: Int {
        return self.spliterator.estimatedSize
    }
}
