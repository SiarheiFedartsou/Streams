//
//  SliceSpliterator.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 03.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

struct SliceSpliterator<T> : SpliteratorProtocol {

    private let sliceOrigin: IntMax
    private let sliceFence: IntMax
    
    private var spliterator: AnySpliterator<T>
    private var index: IntMax
    private var fence: IntMax
    
    
    init(spliterator: AnySpliterator<T>, sliceOrigin: IntMax, sliceFence: IntMax, origin: IntMax, fence: IntMax) {
        assert(spliterator.characteristics.contains(.subsized))
        
        self.spliterator = spliterator
        self.sliceOrigin = sliceOrigin
        self.sliceFence = sliceFence
        self.index = origin
        self.fence = fence
    }
    
    mutating func advance() -> T? {
        if sliceOrigin >= fence {
            return nil
        }
        
        while sliceOrigin > index {
            let _ = spliterator.advance()
            index += 1
        }
        
        if index >= fence {
            return nil
        }
        
        index += 1
        
        return spliterator.advance()
    }
    
    mutating func forEachRemaining(_ each: (T) -> ()) {
        if sliceOrigin >= fence || index >= fence {
            return
        }
        
        if index >= sliceOrigin && (index + spliterator.estimatedSize) <= sliceFence {
            spliterator.forEachRemaining(each)
            index = fence
        } else {
            while sliceOrigin > index {
                let _ = spliterator.advance()
                index += 1
            }
            for _ in index..<fence {
                if let element = spliterator.advance() {
                    each(element)
                }
            }
        }
    }
    
    mutating func split() -> AnySpliterator<T>? {
        if sliceOrigin >= fence || index >= fence {
            return nil
        }
        
        while true {
            guard let leftSplit = spliterator.split() else { return nil }
            
            let leftSplitFenceUnbounded = index + leftSplit.estimatedSize
            let leftSplitFence = min(leftSplitFenceUnbounded, sliceFence)
            if sliceOrigin >= leftSplitFence {
                index = leftSplitFence
            } else if leftSplitFence >= sliceFence {
                spliterator = leftSplit
                fence = leftSplitFence
            } else if index >= sliceOrigin && leftSplitFenceUnbounded <= sliceFence {
                index = leftSplitFence
                return leftSplit
            } else {
                
                let spliterator = SliceSpliterator(spliterator: leftSplit, sliceOrigin: sliceOrigin, sliceFence: sliceFence, origin: index, fence: leftSplitFence)
                index = leftSplitFence
                return AnySpliterator(spliterator)
            }
        }
    }
    
    var estimatedSize: IntMax {
        return (sliceOrigin < fence) ? fence - max(sliceOrigin, index) : 0;
    }
    
    var characteristics: SpliteratorCharacteristics {
        return spliterator.characteristics
    }

}
