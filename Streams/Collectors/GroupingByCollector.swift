//
//  GroupingByCollector.swift
//  Streams
//
//  Created by Sergey Fedortsov on 04.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//


struct GroupingByCollector<T, K: Hashable> : Collector {

    let classifier: (T) -> K
    
    init(classifier: @escaping (T) -> K) {
        self.classifier = classifier
    }
    
    var accumulator: ([K:[T]], T) -> [K:[T]] {
        return { (accumulator: [K:[T]], element: T) in
            var map = accumulator
            let group = self.classifier(element)
            
            if var mapGroup = map[group] {
                mapGroup.append(element)
                map[group] = mapGroup
            } else {
                map[group] = [element]
            }
            return map
        }
    }

    var combiner: ([K:[T]], [K:[T]]) -> [K:[T]] = {
        var result = $0
        for (group, groupElements) in $1 {
            if var mapGroup = result[group] {
                mapGroup.append(contentsOf: groupElements)
                result[group] = mapGroup
            } else {
                result[group] = groupElements
            }
        }
        return result
    }
    
    var finisher: ([K:[T]]) -> [K:[T]] = { $0 }
    var containerSupplier: () -> [K:[T]] = { [K:[T]]() }
}

public func grouping<T, K: Hashable>(by classifier: @escaping (T) -> K) -> AnyCollector<T, [K: [T]], [K: [T]]> {
    return AnyCollector(GroupingByCollector(classifier: classifier))
}
