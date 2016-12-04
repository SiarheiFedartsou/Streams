//
//  Collector.swift
//  Streams
//
//  Created by Sergey Fedortsov on 04.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

protocol Collector {
    associatedtype InputElement
    associatedtype Accumulator
    associatedtype Result
    
    var accumulator: (Accumulator, InputElement) -> Accumulator { get }
    var combiner: (Accumulator, Accumulator) -> Accumulator { get }
    var finisher: (Accumulator) -> Result { get }
    var containerSupplier: () -> Accumulator { get }
}
