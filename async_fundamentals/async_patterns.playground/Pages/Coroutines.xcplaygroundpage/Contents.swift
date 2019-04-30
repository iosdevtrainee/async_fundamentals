// Coroutines

import Cocoa

enum CoroutineState {
  case Fresh, Running, Blocked, Canceled, Done
}

struct CoroutineCancellation: ErrorType {}

class CoroutineImpl<InputType, YieldType> {
  let body: (_ yield: YieldType throws -> InputType) throws -> Void
  
  var state = CoroutineState.Fresh
  
  let lock = NSCondition()
  
  var inputValue: InputType?
  var yieldValue: YieldType?
  
  init(body: (_ yield: YieldType throws -> InputType) throws -> Void) {
    self.body = body
  }
  
  func getNext(value: InputType) -> YieldType? {
    lock.lock()
    inputValue = value
    unblock()
    while state == .Running {
      lock.wait()
    }
    let result = yieldValue
    yieldValue = nil
    
    lock.unlock()
    
    return result
  }
  
  func cancel() {
    lock.lock()
    state = .Canceled
    lock.signal()
    lock.unlock()
  }
  
  private func unblock() {
    switch state {
    case .Fresh:
      state = .Running
      dispatch_async(dispatch_get_global_queue(0, 0), {
        do {
          try self.body(yield: self.yield)
        } catch {}
        self.lock.lock()
        self.state = .Done
        self.lock.signal()
        self.lock.unlock()
      })
    case .Running:
      preconditionFailure("Must never call unblock() while running")
    case .Blocked:
      state = .Running
      lock.signal()
    case .Canceled:
      break
    case .Done:
      break
    }
  }
  
  private func yield(value: YieldType) throws -> InputType {
    lock.lock()
    self.yieldValue = value
    state = .Blocked
    lock.signal()
    while state == .Blocked {
      lock.wait()
    }
    let canceled = state == .Canceled
    let input = inputValue
    inputValue = nil
    lock.unlock()
    
    if canceled {
      throw CoroutineCancellation()
    }
    return input!
  }
}

class Coroutine<InputType, YieldType> {
  let impl: CoroutineImpl<InputType, YieldType>
  
  init(_ body: (_ yield: YieldType throws -> InputType) throws -> Void) {
    impl = CoroutineImpl(body: body)
  }
  
  deinit {
    impl.cancel()
  }
  
  func getNext(value: InputType) -> YieldType? {
    return impl.getNext(value)
  }
}

func coroutine<InputType, YieldType>(type: (InputType, YieldType).Type, _ body: (_ yield: YieldType throws -> InputType) throws -> Void) -> (InputType -> YieldType?){
  let obj = Coroutine(body)
  return obj.getNext
}





