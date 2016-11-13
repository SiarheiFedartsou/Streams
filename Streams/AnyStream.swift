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
    
    func limit(_ size: Int) -> AnyStream<T> {
        return box.limit(size)
    }
    
    func skip(_ size: Int) -> AnyStream<T> {
        return box.skip(size)
    }
    
    func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T {
        return box.reduce(identity: identity, accumulator: accumulator)
    }
    
    func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool {
        return box.anyMatch(predicate)
    }
    
    func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool {
        return box.allMatch(predicate)
    }
    
    func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool {
        return box.noneMatch(predicate)
    }
    
    func forEach(_ each: @escaping (T) -> ()) {
        box.forEach(each)
    }
    
    var first: T? {
        return box.first
    }
    
    var any: T? {
        return box.any
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
    func limit(_ size: Int) -> AnyStream<T> {
        _abstract()
    }
    func skip(_ size: Int) -> AnyStream<T> {
        _abstract()
    }
    func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T {
        _abstract()
    }
    func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool {
        _abstract()
    }
    func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool {
        _abstract()
    }
    func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool {
        _abstract()
    }
    func forEach(_ each: @escaping (T) -> ()) {
        _abstract()
    }
    var first: T? {
        _abstract()
    }
    var any: T? {
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
    override func limit(_ size: Int) -> AnyStream<Base.T> {
        return base.limit(size)
    }
    override func skip(_ size: Int) -> AnyStream<Base.T> {
        return base.skip(size)
    }
    override func reduce(identity: Base.T, accumulator: @escaping (Base.T, Base.T) -> Base.T) -> Base.T {
        return base.reduce(identity: identity, accumulator: accumulator)
    }
    override func anyMatch(_ predicate: @escaping (Base.T) -> Bool) -> Bool {
        return base.anyMatch(predicate)
    }
    override func allMatch(_ predicate: @escaping (Base.T) -> Bool) -> Bool {
        return base.allMatch(predicate)
    }
    override func noneMatch(_ predicate: @escaping (Base.T) -> Bool) -> Bool {
        return base.noneMatch(predicate)
    }
    override func forEach(_ each: @escaping (Base.T) -> ()) {
        base.forEach(each)
    }
    override var first: Base.T? {
        return base.first
    }
    override var any: Base.T? {
        return base.any
    }
}
