//
//  CastingSpliterator.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 30.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

struct CastingSpliterator<T> : SpliteratorProtocol {
    var spliterator: UntypedSpliteratorProtocol
    
    mutating func advance() -> T? {
        return spliterator.advance() as! T?
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void) {
        spliterator.forEachRemaining { (element) in
            each(element as! T)
        }
    }
    
    mutating func split() -> AnySpliterator<T>? {
        if let split = spliterator.split() {
            return AnySpliterator(CastingSpliterator<T>(spliterator: split))
        } else {
            return nil
        }
        
    }
    
    var options: StreamOptions {
        return spliterator.options
    }
    
    var estimatedSize: Int {
        return spliterator.estimatedSize
    }
}
