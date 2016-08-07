/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This file contains the foundational subclass of NSOperation.
 */

import Foundation

/**
 The subclass of `NSOperation` from which all other operations should be derived.
 This class adds both Conditions and Observers, which allow the operation to define
 extended readiness requirements, as well as notify many interested parties
 about interesting operation state changes
 */
public class DriftOperation: Operation {
    
    // use the KVO mechanism to indicate that changes to "state" affect other properties as well
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }
    
    // MARK: State Management
    
    /// The state of DriftOperation
    public enum State: Int, Comparable {
        
        /// The initial state of an `DriftOperation`.
        case initialized
        
        /// The `DriftOperation` is ready to begin evaluating conditions.
        case pending
        
        /// The `DriftOperation` is evaluating conditions.
        case evaluatingConditions
        
        /**
         The `DriftOperation`'s conditions have all been satisfied, and it is ready
         to execute.
         */
        case ready
        
        /// The `DriftOperation` is executing.
        case executing
        
        /**
         Execution of the `DriftOperation` has finished, but it has not yet notified
         the queue of this.
         */
        case finishing
        
        /// The `DriftOperation` has finished executing.
        case finished
        
        /// Return `true` if `self` can transition to `target` state.
        func canTransitionToState(_ target: State) -> Bool {
            switch (self, target) {
            case (.initialized, .pending):
                return true
            case (.pending, .evaluatingConditions):
                return true
            case (.evaluatingConditions, .ready):
                return true
            case (.ready, .executing):
                return true
            case (.ready, .finishing):
                return true
            case (.executing, .finishing):
                return true
            case (.finishing, .finished):
                return true
            default:
                return false
            }
        }
    }
    
    internal func _willEnqueue() {
        state = .pending
        willEnqueue()
    }
    
    /// Called when the operation is about to enqueue in `DriftOperationQueue`
    public func willEnqueue() {
        
    }
    
    /// Private storage for the `state` property that will be KVO observed.
    private var _state = State.initialized
    
    /// A lock to guard reads and writes to the `_state` property
    private let stateLock = NSLock()
    
    /// Current state of the operation. (read-only)
    public private(set) var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        set(newState) {
            /*
             It's important to note that the KVO notifications are NOT called from inside
             the lock. If they were, the app would deadlock, because in the middle of
             calling the `didChangeValueForKey()` method, the observers try to access
             properties like "isReady" or "isFinished". Since those methods also
             acquire the lock, then we'd be stuck waiting on our own lock. It's the
             classic definition of deadlock.
             */
            willChangeValue(forKey: "state")
            
            stateLock.withCriticalScope {
                guard _state != .finished else {
                    return
                }
                
                assert(_state.canTransitionToState(newState), "Performing invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: "state")
        }
    }
    
    // Here is where we extend our definition of "readiness".
    public override var isReady: Bool {
        switch state {
            
        case .initialized:
            // If the operation has been cancelled, "isReady" should return true
            return isCancelled
            
        case .pending:
            // If the operation has been cancelled, "isReady" should return true
            guard !isCancelled else {
                return true
            }
            
            // If super isReady, conditions can be evaluated
            if super.isReady {
                evaluateConditions()
            }
            
            // Until conditions have been evaluated, "isReady" returns false
            return false
            
        case .ready:
            return super.isReady || isCancelled
            
        default:
            return false
        }
    }
    
    /// If `true`, the operation is given "User Initiated" Quality of Class.
    public var userInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        set {
            assert(state < .executing, "Cannot modify userInitiated after execution has begun.")
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    private func evaluateConditions() {
        assert(state == .pending && !isCancelled, "evaluateConditions() was called out-of-order")
        
        state = .evaluatingConditions
        conditions.evaluate(forOperation: self) { failures in
            self._internalErrors.append(contentsOf: failures)
            self.state = .ready
        }
    }
    
    internal var exclusivityCategories: [MutualExclusivityCategory] = []
    
    /// Sets an operation as being mutually exclusive in `category`.
    ///
    /// - Warning: This method needs to be called before enqueuing.
    public final func setMutuallyExclusive(inCategory category: MutualExclusivityCategory) {
        assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")
        exclusivityCategories.append(category)
    }
    
    // MARK: Observers and Conditions
    
    private(set) var conditions = [DriftOperationCondition]()
    
    /// Makes `self` dependent on the evalution of `condition`.
    ///
    /// - Warning: This method needs to be called before enqueuing.
    public func addCondition(_ condition: DriftOperationCondition) {
        assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")
        
        conditions.append(condition)
    }
    
    private(set) var observers = [DriftOperationObserver]()
    
    /// Assigns an `observer` to `self`
    ///
    /// - Warning: This method needs to be called before enqueuing.
    public func addObserver(_ observer: DriftOperationObserver) {
        assert(state < .executing, "Cannot modify observers after execution has begun.")
        observers.append(observer)
    }
    
    public override func addDependency(_ operation: Operation) {
        assert(state < .executing, "Dependencies cannot be modified after execution has begun.")
        super.addDependency(operation)
    }
    
    public struct DependencyOptions: OptionSet {
        public var rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let ExpectSuccess = DependencyOptions(rawValue: 1 << 0)
    }
    
    /// Makes the receiver dependent on the completion of the specified operation.
    ///
    /// - Parameter expectSuccess: If `true`, `self` operation will fail if `operation` fails.
    public func addDependency(_ operation: DriftOperation, options: [DependencyOptions]) {
        addDependency(operation)
        if options.contains(.ExpectSuccess) {
            addCondition(NoFailedDependency(dependency: operation))
        }
    }
    
    // MARK: Execution and Cancellation
    
    public override final func start() {
        // NSOperation.start() contains important logic that shouldn't be bypassed.
        super.start()
        
        // If the operation has been cancelled, we still need to enter the "Finished" state.
        if isCancelled {
            finish()
        }
    }
    
    public override final func main() {
        assert(state == .ready, "This operation must be performed on an operation queue.")
        
        if _internalErrors.isEmpty && !isCancelled {
            state = .executing
            for observer in observers {
                observer.operationDidStart(self)
            }
            execute()
        }
        else {
            finish()
        }
    }
    
    /**
     Begins the execution of the `DriftOperation`.
     
     `execute()` is the entry point of execution for all `DriftOperation` subclasses.
     If you subclass `DriftOperation` and wish to customize its execution, you would
     do so by overriding the `execute()` method.
     
     At some point, your `DriftOperation` subclass must call one of the "finish"
     methods defined below; this is how you indicate that your operation has
     finished its execution, and that operations dependent on yours can re-evaluate
     their readiness state.
     */
    public func execute() {
        print("\(self.dynamicType) must override `execute()`.")
        finish()
    }
    
    private var _internalErrors = [Error]()
    
    /// Cancels operation with `error`.
    public func cancel(with error: Error) {
        _internalErrors.append(error)
        cancel()
    }
    
    /// An array of errors reported by the operation during it's execution. (read-only)
    ///
    /// - Returns: `nil` if `DriftOperation` is not finished yet. Empty array if `DriftOperation` was finished successfully.
    ///
    /// - Warning: You can't access this property inside the observers (you'll receive `nil`), because they are called slightly *before* finishing.
    public final var errors: [Error]? {
        return state == .finished ? _combinedErrors : nil
    }
    
    /// Adds an `operation` to the queue on which `self` is executing.
    public final func produceOperation(_ operation: Operation) {
        for observer in observers {
            observer.operation(self, didProduceOperation: operation)
        }
    }
    
    // MARK: Finishing
    
    /**
     A private property to ensure we only notify the observers once that the
     operation has finished.
     */
    private var hasFinishedAlready = false
    private var _combinedErrors = [Error]()
    
    /// Puts `self` in `finished` state.
    ///
    /// - Parameter errors: Reported errors
    public final func finish(withErrors errors: [Error] = []) {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            state = .finishing
            
            _combinedErrors = _internalErrors + errors
            finished(_combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self, errors: _combinedErrors)
            }
            
            state = .finished
        }
    }
    
    /// Finishes operation reporting single error.
    ///
    /// - Parameter error: Reported error.
    public final func finish(with error: Error) {
        finish(withErrors: [error])
    }
    
    /// Called when `self` is about to enter it's `finished` state. For use by subclassers.
    public func finished(_ errors: [Error]) {
        // No op.
    }
    
    @available(*, deprecated, message: "Waiting on operations is an anti-pattern. Use this ONLY if you're absolutely sure there is No Other Way™.")
    public override final func waitUntilFinished() {
        /*
         Waiting on operations is almost NEVER the right thing to do. It is
         usually superior to use proper locking constructs, such as `dispatch_semaphore_t`
         or `dispatch_group_notify`, or even `NSLocking` objects. Many developers
         use waiting when they should instead be chaining discrete operations
         together using dependencies.
         
         To reinforce this idea, invoking `waitUntilFinished()` will cause Xcode warning, 
         as incentive for you to find a more appropriate way to express
         the behavior you're wishing to create.
         */
    }
    
}

// Simple operator functions to simplify the assertions used above.
public func <(lhs: DriftOperation.State, rhs: DriftOperation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func ==(lhs: DriftOperation.State, rhs: DriftOperation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
