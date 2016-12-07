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

protocol Task {
    associatedtype Result
    func invoke() -> Result
}

final class ReduceTask<T: Initializable> : Task {
    
    var spliterator: AnySpliterator<T>
    let accumulator: (T, T) -> T
    
    init(spliterator: AnySpliterator<T>, accumulator: @escaping (T, T) -> T) {
        self.spliterator = spliterator
        self.accumulator = accumulator
    }
    
    func invoke() -> T {
        if let splitted = spliterator.split() {
            return accumulator(ReduceTask(spliterator: splitted, accumulator: accumulator).invoke(),
                                 ReduceTask(spliterator: spliterator, accumulator: accumulator).invoke())
        } else {
            var result = T()
            spliterator.forEachRemaining {
                result = accumulator(result, $0)
            }
            return result
        }
    }
}
