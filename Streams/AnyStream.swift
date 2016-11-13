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
    
    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T> {
        return box.filter(predicate)
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R> {
        return box.map(mapper)
    }
    
    
    func forEach(_ each: @escaping (T) -> ()){
        box.forEach(each)
    }
}

class AnyStreamBoxBase<T>: StreamProtocol {
    
    var spliterator: AnySpliterator<T> {
        _abstract()
    }

    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T> {
        _abstract()
    }
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R> {
        _abstract()
    }
    func forEach(_ each: @escaping (T) -> ()) {
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
    
    
    override func filter(_ predicate: @escaping (Base.T) -> Bool) -> AnyStream<Base.T> {
        return base.filter(predicate)
    }
    
    override func map<R>(_ mapper: @escaping (Base.T) -> R) -> AnyStream<R> {
        return base.map(mapper)
    }
    override func forEach(_ each: @escaping (Base.T) -> ()) {
        base.forEach(each)
    }
}
