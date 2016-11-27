//
//  PipelineWrappingSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 27.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


struct PipelineWrappingSpliterator<In, Out> : SpliteratorProtocol {
    mutating func advance() -> Out? {
        
    }
    
    mutating func forEachRemaining(_ each: (Out) -> Void) {
        
    }
    
    mutating func split() -> AnySpliterator<Out>? {
        
    }
    
    var options: StreamOptions {
    
    }
    var estimatedSize: Int {
    }
}
