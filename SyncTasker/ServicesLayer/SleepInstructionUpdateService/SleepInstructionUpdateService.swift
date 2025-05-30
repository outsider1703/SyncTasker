//
//  SleepInstructionUpdateService.swift
//  SyncTasker
//
//  Created by ingvar on 30.05.2025.
//

import Foundation
import Combine

protocol SleepInstructionUpdateServiceProtocol: AnyObject {
    var updatePublisher: AnyPublisher<Void, Never> { get }
    func notifyUpdate()
}

class SleepInstructionUpdateService: SleepInstructionUpdateServiceProtocol {
    private let updateSubject = PassthroughSubject<Void, Never>()
    
    var updatePublisher: AnyPublisher<Void, Never> {
        updateSubject.eraseToAnyPublisher()
    }
    
    func notifyUpdate() {
        updateSubject.send()
    }
}
