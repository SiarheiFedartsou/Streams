//
//  Utils.swift
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

