//: [Previous](@previous)

import Foundation

var str = "Hello, playground"

enum Result<Value> {
    case error(Error)
    case value(Value)
}

class Future<Value> {
    // observer on the future
    typealias Callback = (Result<Value>) -> Void
    private var result: Result<Value>?{
        didSet {
            result.map { (result: Result<Value>) -> U in
                report()
            }
        }
    }
    
    public func observe(with callback:Callback){
        listeners.append(callback)
        
        // Only called if a result is set call backs
        result.map { value in
          callback(value)
        }
    }
    
    private lazy var listeners = [Callback]()
    
    private func report(){
        for callback in listeners {
            // guaranteed to have a value i.e. not nil
            callback(result)
        }
    }
}

class Promise<Value>: Future<Value> {
    init(value:Value? = nil){
        // equivalent to result = value.map { Result.value }
        result = value.map { Result.value($0) }
    }
    
    public func resolve(with value: Value){
        result = .value(value)
    }
    
    public func reject(with error:Error){
        result = .error(error)
    }
}

// Needs to be studied

extension Future {
    // handler is an Either or Maybe perfect for Result
    public func chain<NewValue>(with handler: @escaping (Value) throws -> Future<NextValue>  ){
        // return a new promise which is also a future
        let promise = Promise<NewValue>()
        
        observe { (result) in
            switch result {
            case .value(let value):
                // recursive step
                do {
                    let future = try closure(value)
                    
                    future.observe { (result) in
                        switch result {
                        case .value(let value):
                            promise.resolve(with: NewValue)
                        case .error(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .error(let error):
                promise.reject(with: error)
            }
        }
        return promise
    }
}

extension Future {
    public func transform<NextValue>(with closure: @escaping(Value) throws -> NextValue){
        return chain { value in
            return try Promise(value: closure(value))
        }
    }
}
