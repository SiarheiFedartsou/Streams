//
//  DistinctSpliterator.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 30.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

fileprivate final class SeenBox<T: Hashable> {
    private var seen = Set<T>()
    private let syncQueue = DispatchQueue(label: "com.streams.distinct_spliterator_queue")
    
    func insert(_ element: T) -> Bool {
        var result: Bool = false
        syncQueue.sync {
            (result, _) = seen.insert(element)
        }
        return result
    }
    
}

final class DistinctSpliterator<T: Hashable> : SpliteratorProtocol {
    
    private var seen: SeenBox<T>
    var spliterator: AnySpliterator<T>
    
    let syncQueue: DispatchQueue = DispatchQueue(label: "com.streams.distinct_spliterator_queue")
    
    convenience init(spliterator: AnySpliterator<T>) {
        self.init(spliterator: spliterator, seen: SeenBox<T>())
    }
    
    private init(spliterator: AnySpliterator<T>, seen: SeenBox<T>) {
        self.spliterator = spliterator
        self.seen = seen
    }
    
    func advance() -> T? {
        while let element = spliterator.advance() {
            if seen.insert(element) {
                return element
            }
        }
        return nil
    }
    
    func forEachRemaining(_ each: (T) -> Void) {
        spliterator.forEachRemaining { (element) in
            if seen.insert(element) {
                each(element)
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
