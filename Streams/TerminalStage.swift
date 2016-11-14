//
//  TerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


protocol TerminalStage : SinkProtocol {
    associatedtype Result
    func evaluate() -> Result
}
