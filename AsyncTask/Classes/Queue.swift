//
//  Queue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public struct Queue<Element> {
    
    private let list = LinkedList<Element>()
    
    public var isEmpty: Bool { list.isEmpty }
    
    public var length: Int { return list.length }
    
    @discardableResult
    public func dequeue() -> Element? {
        guard !list.isEmpty else { return nil }
        return list.remove(at: 0)
    }
    
    public func enqueue(_ newElement: Element) {
        list.append(value: newElement)
    }
    
    public func peek() -> Element? {
        return list.first?.value
    }
}

extension Queue : ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        elements.forEach { list.append(value: $0) }
    }
}

extension Queue {
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try list.forEach(body)
    }
    
    public func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try list.sort(by: areInIncreasingOrder)
    }
}
