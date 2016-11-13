//
//  AnyStream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//


@inline(never)
internal func _abstract(
    file: StaticString = #file,
    line: UInt = #line
    ) -> Never {
    fatalError("Method must be overridden", file: file, line: line)
}



struct AnyStream<T>: StreamProtocol {
    
    private let box: AnyStreamBoxBase<T>
    
    init<Base: StreamProtocol>(_ base: Base) where Base.T == T {
        self.box = AnyStreamBox(base)
    }
    
    var spliterator: AnySpliterator<T> {
        return box.spliterator
    }
    
    var isParallel: Bool {
        return box.isParallel
    }
    
    var parallel: AnyStream<T> {
        return box.parallel
    }
    var sequential: AnyStream<T> {
        return box.sequential
    }
    var unordered: AnyStream<T> {
        return box.unordered
    }
    
    
    func filter(_ predicate: (T) -> Bool) -> AnyStream<T> {
        return box.filter(predicate)
    }
    
    func map<R>(_ mapper: (T) -> R) -> AnyStream<R> {
        return box.map(mapper)
    }
    
    
    func forEach(_ each: (T) -> ()){
        box.forEach(each)
    }
}

class AnyStreamBoxBase<T>: StreamProtocol {
    
    var spliterator: AnySpliterator<T> {
        _abstract()
    }
    
    var isParallel: Bool {
        _abstract()
    }
    
    var parallel: AnyStream<T> {
        _abstract()
    }
    var sequential: AnyStream<T> {
        _abstract()
    }
    var unordered: AnyStream<T> {
        _abstract()
    }
    func filter(_ predicate: (T) -> Bool) -> AnyStream<T> {
        _abstract()
    }
    func map<R>(_ mapper: (T) -> R) -> AnyStream<R> {
        _abstract()
    }
    func forEach(_ each: (T) -> ()) {
        _abstract()
    }
}

final class AnyStreamBox<Base: StreamProtocol>: AnyStreamBoxBase<Base.T> {
    private var base: Base
    init(_ base: Base)  {
        self.base = base
    }
    
    override var spliterator: AnySpliterator<Base.T> {
        return base.spliterator
    }
    
    override var isParallel: Bool {
        return base.isParallel
    }
    
    override var parallel: AnyStream<Base.T> {
        return base.parallel
    }
    override var sequential: AnyStream<Base.T> {
        return base.sequential
    }
    override var unordered: AnyStream<Base.T> {
        return base.unordered
    }
    
    
    override func filter(_ predicate: (Base.T) -> Bool) -> AnyStream<Base.T> {
        return base.filter(predicate)
    }
    
    override func map<R>(_ mapper: (Base.T) -> R) -> AnyStream<R> {
        return base.map(mapper)
    }
    override func forEach(_ each: (Base.T) -> ()) {
        base.forEach(each)
    }
}
