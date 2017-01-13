//
//  TerminalOperation.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

protocol TerminalOperationProtocol {
    associatedtype Result
    
    func evaluateParallel(forPipelineStage: UntypedPipelineStageProtocol, spliterator: UntypedSpliteratorProtocol?) -> Result
    func evaluateSequential(forPipelineStage: UntypedPipelineStageProtocol, spliterator: UntypedSpliteratorProtocol?) -> Result
}
