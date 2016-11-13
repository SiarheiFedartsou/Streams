//
//  Stream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.10.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation
import Swift

protocol StreamProtocol {
    associatedtype T
    var spliterator: AnySpliterator<T> { get }
  
    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T>
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R>
    
    func forEach(_ each: @escaping (T) -> ())
}
