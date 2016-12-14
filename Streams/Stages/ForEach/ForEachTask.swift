//
//  ForEachTask.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

//protocol Task {
//    associatedtype Result
//    func invoke() -> Result
//}

final class ForEachTask<T> : Task {
    
    var spliterator: UntypedSpliteratorProtocol
    let sink: UntypedSinkProtocol
    let each: (T) -> ()
    
    
    init(spliterator: UntypedSpliteratorProtocol, sink: UntypedSinkProtocol, each: @escaping (T) -> ()) {
        self.spliterator = spliterator
        self.sink = sink
        self.each = each
    }
    
    private convenience init(parent: ForEachTask<T>) {
        self.init(spliterator: parent.spliterator, sink: parent.sink, each: parent.each)
    }
    
    func invoke() -> Void {
        if let splitted = spliterator.split() {
            
            let leftRightOps = [
                { ForEachTask(spliterator: splitted, sink: self.sink, each: self.each).invoke() },
                { ForEachTask(spliterator: self.spliterator, sink: self.sink, each: self.each).invoke() }
            ]
            
            DispatchQueue.concurrentPerform(iterations: 2, execute: {
                leftRightOps[$0]()
            })
        } else {
            spliterator.forEachRemaining {element in
                self.sink.consume(element)
            }
        }
    }
}
