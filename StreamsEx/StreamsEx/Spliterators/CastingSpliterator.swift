//
//  CastingSpliterator.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 30.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

struct CastingSpliterator<Origin, T> : SpliteratorProtocol {
    var spliterator: AnySpliterator<Origin>
    
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
            return AnySpliterator(CastingSpliterator<Origin, T>(spliterator: split))
        } else {
            return nil
        }
    }
    
    var estimatedSize: IntMax {
        return spliterator.estimatedSize
    }
    
    var exactSize: IntMax? {
        return spliterator.exactSize
    }
    
    var characteristics: SpliteratorCharacteristics {
        return spliterator.characteristics
    }
}
