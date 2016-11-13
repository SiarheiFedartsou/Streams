//
//  Supplier.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol SupplierProtocol {
    associatedtype T
    func supply() -> T?
}

struct AnySupplier<T> : SupplierProtocol {
    private let _supply: () -> T?
    init<Supplier: SupplierProtocol>(_ supplier: Supplier) where Supplier.T == T
    {
        _supply = supplier.supply
    }
    
    func supply() -> T? {
        return _supply()
    }
}
