//
//  SinkFactory.swift
//  Streams
//
//  Created by Sergey Fedortsov on 02.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//


internal protocol SinkFactory {
    associatedtype SinkElement
    func makeSink() -> AnySink<SinkElement>
}

struct AnySinkFactory<T> : SinkFactory {
    private let box: AnySinkFactoryBoxBase<T>
    
    init<Base: SinkFactory>(_ base: Base) where Base.SinkElement == T {
        box = AnySinkFactoryBox(base)
    }
    
    func makeSink() -> AnySink<T> {
        return box.makeSink()
    }
}

class AnySinkFactoryBoxBase<T>: SinkFactory {
    func makeSink() -> AnySink<T> {
        _abstract()
    }
}

final class AnySinkFactoryBox<Base: SinkFactory>: AnySinkFactoryBoxBase<Base.SinkElement> {
    private var base: Base
    init(_ base: Base)  {
        self.base = base
    }
    
    override func makeSink() -> AnySink<Base.SinkElement> {
        return base.makeSink()
    }
}

