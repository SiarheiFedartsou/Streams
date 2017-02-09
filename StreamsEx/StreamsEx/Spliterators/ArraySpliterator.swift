//
//  ArraySpliterator.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 03.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

struct ArraySpliterator<T> : SpliteratorProtocol  {
    
    var array: [T]
    
    private var index: Int
    private let fence: Int
    let characteristics: SpliteratorCharacteristics
    
    
    init(array: [T])
    {
        self.init(array: array, origin: array.startIndex, fence: array.endIndex)
    }
    
    
    
    init(array: [T], origin: Int, fence: Int)
    {
        self.array = array
        self.index = origin
        self.fence = fence
        
        self.characteristics = [.sized, .subsized]
    }
    
    
    mutating func advance() -> T? {
        if index == fence { return nil }
        
        let element = array[index]
        array.formIndex(after: &index)
        return element
    }
    
    var estimatedSize: IntMax {
        return IntMax(fence - index)
    }
    
    mutating func split() -> AnySpliterator<T>? {
        guard estimatedSize > 512 else { return nil }
        let lo = index
        let mid = array.index(lo, offsetBy: array.distance(from: lo, to: fence) / 2)
        guard lo < mid else { return nil }
        
        index = mid
        
        return AnySpliterator(ArraySpliterator(array: array,
                                                    origin: lo,
                                                    fence: mid))
    }
    

}
