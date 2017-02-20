//
//  SetSpliterator.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 03.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

// TODO: implement common spliterator for all collections?

struct SetSpliterator<T: Hashable> : SpliteratorProtocol {
    private let set: Set<T>
    
    private var index: Set<T>.Index
    private let fence: Set<T>.Index
    
    init(set: Set<T>) {
        self.init(set: set, origin: set.startIndex, fence: set.endIndex)
    }
    
    init(set: Set<T>, origin: Set<T>.Index, fence: Set<T>.Index) {
        self.set = set
        self.index = origin
        self.fence = fence
    }
    
    mutating func advance() -> T? {
        if index == fence { return nil }
        
        let element = set[index]
        set.formIndex(after: &index)
        return element
    }
    
    mutating func split() -> AnySpliterator<T>? {
        let lo = index
        let mid = set.index(lo, offsetBy: set.distance(from: lo, to: fence) / 2)
        guard lo < mid else { return nil }
        
        index = mid
        
        return AnySpliterator(SetSpliterator(set: set,
                                               origin: lo,
                                               fence: mid))
    }
    
    var estimatedSize: IntMax {
        return IntMax(set.count)
    }
    
    var characteristics: SpliteratorCharacteristics {
        return [.sized, .distinct]
    }
}
