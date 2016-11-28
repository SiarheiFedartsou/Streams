//
//  Summable.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

public protocol Summable {
    init()
    static func+(left: Self, right: Self) -> Self  
}

extension Int : Summable {}
extension Float : Summable {}
extension Double : Summable {}
