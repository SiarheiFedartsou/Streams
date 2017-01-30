//
//  DistinctSpliterator.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 30.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

final class DistinctSpliterator<T: Hashable> : SpliteratorProtocol {
    
    var seen: Set<T> = Set<T>()
    var spliterator: AnySpliterator<T>
    
    let syncQueue: DispatchQueue = DispatchQueue(label: "com.streams.distinct_spliterator_queue")
    
    convenience init(spliterator: AnySpliterator<T>) {
        self.init(spliterator: spliterator, seen: Set<T>())
    }
    
    init(spliterator: AnySpliterator<T>, seen: Set<T>) {
        self.spliterator = spliterator
        self.seen = seen
    }
    
    func advance() -> T? {
        while let element = spliterator.advance() {
            var result: T? = nil
            syncQueue.sync {
                if !seen.contains(element) {
                    seen.insert(element)
                    result = element
               }
            }
            return result
        }
        return nil
    }
    
    func forEachRemaining(_ each: (T) -> Void) {
        spliterator.forEachRemaining { (element) in
            var result: T? = nil
            syncQueue.sync {
                if !seen.contains(element) {
                    seen.insert(element)
                    result = element
                }
            }
            if let result = result {
                each(result)
            }
        }
    }
    
    func split() -> AnySpliterator<T>? {
        if let split = spliterator.split() {
            return AnySpliterator(DistinctSpliterator(spliterator: split, seen: seen))
        } else {
            return nil
        }
    }
    
    var options: StreamOptions {
        return StreamOptions()
    }
    
    var estimatedSize: Int {
        return 0
    }
}
