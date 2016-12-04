//
//  AnyCollector.swift
//  Streams
//
//  Created by Sergey Fedortsov on 04.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

public struct AnyCollector<InputElement, Accumulator, Result> : Collector {
    private let box: AnyCollectionBoxBase<InputElement, Accumulator, Result>
    
    init<C: Collector>(_ collector: C) where C.InputElement == InputElement, C.Accumulator == Accumulator, C.Result == Result
    {
        box = AnyCollectionBox(collector)
    }
    
    
    var accumulator: (Accumulator, InputElement) -> Accumulator {
        return box.accumulator
    }
    
    var combiner: (Accumulator, Accumulator) -> Accumulator {
        return box.combiner
    }
    
    var finisher: (Accumulator) -> Result {
        return box.finisher
    }
    
    var containerSupplier: () -> Accumulator {
        return box.containerSupplier
    }
}

class AnyCollectionBoxBase<InputElement, Accumulator, Result>: Collector {
    var accumulator: (Accumulator, InputElement) -> Accumulator {
        _abstract()
    }
    
    var combiner: (Accumulator, Accumulator) -> Accumulator {
        _abstract()
    }
    
    var finisher: (Accumulator) -> Result {
        _abstract()
    }
    
    var containerSupplier: () -> Accumulator {
        _abstract()
    }
}

final class AnyCollectionBox<Base: Collector> : AnyCollectionBoxBase<Base.InputElement, Base.Accumulator, Base.Result> {
    private var base: Base
    init(_ base: Base)  {
        self.base = base
    }

    override var accumulator: (Base.Accumulator, Base.InputElement) -> Base.Accumulator {
        return base.accumulator
    }
    
    override var combiner: (Base.Accumulator, Base.Accumulator) -> Base.Accumulator {
        return base.combiner
    }
    
    override var finisher: (Base.Accumulator) -> Base.Result {
        return base.finisher
    }
    
    override var containerSupplier: () -> Base.Accumulator {
        return base.containerSupplier
    }

}
