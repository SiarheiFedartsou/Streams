//
//  TestTask.swift
//  Streams
//
//  Created by Sergey Fedortsov on 07.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol Initializable {
    init()
}

extension Int : Initializable {}


protocol Task {
    associatedtype Result
    func invoke() -> Result
}

final class ReduceTask<T: Initializable> : Task {
    
    var spliterator: AnySpliterator<T>
    let accumulator: (T, T) -> T
    let dispatchGroup: DispatchGroup
    
    convenience init(spliterator: AnySpliterator<T>, accumulator: @escaping (T, T) -> T) {
        self.init(spliterator: spliterator, accumulator: accumulator, dispatchGroup: DispatchGroup())
    }
    
    private init(spliterator: AnySpliterator<T>, accumulator: @escaping (T, T) -> T, dispatchGroup: DispatchGroup) {
        self.spliterator = spliterator
        self.accumulator = accumulator
        self.dispatchGroup = dispatchGroup
    }
    
    func invoke() -> T {
        if let splitted = spliterator.split() {
            var result1 = T()
            var result2 = T()
            DispatchQueue.concurrentPerform(iterations: 2, execute: {
                if $0 == 0 {
                    result1 = ReduceTask(spliterator: splitted, accumulator: self.accumulator, dispatchGroup: self.dispatchGroup).invoke()
                } else {
                    result2 = ReduceTask(spliterator: self.spliterator, accumulator: self.accumulator, dispatchGroup: self.dispatchGroup).invoke()
                }
            })
            return accumulator(result1, result2)

        } else {
            var result = T()
            spliterator.forEachRemaining {
                result = accumulator(result, $0)
            }
            return result
        }
    }
}
