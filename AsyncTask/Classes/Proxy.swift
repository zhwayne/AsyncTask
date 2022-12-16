//
//  Proxy.swift
//  EasyAlert
//
//  Created by iya on 2021/12/21.
//

import UIKit

class Proxy: NSObject /* & NSProxy */ {

    private weak var target: NSObject!
    
    required init(target: NSObject) {
        super.init()
        self.target = target
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return target.isEqual(object)
    }
    
    override var hash: Int {
        return target.hash
    }
    
    override var superclass: AnyClass? {
        return target.superclass
    }
    
    override func isProxy() -> Bool {
        return true
    }
    
    override func isKind(of aClass: AnyClass) -> Bool {
        return target.isKind(of: aClass)
    }
    
    override func isMember(of aClass: AnyClass) -> Bool {
        return isMember(of: aClass)
    }
    
    override func conforms(to aProtocol: Protocol) -> Bool {
        return target.conforms(to: aProtocol)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return target.responds(to: aSelector)
    }
    
    override var description: String {
        return target.description
    }
    
    override var debugDescription: String {
        return target.debugDescription
    }
}
