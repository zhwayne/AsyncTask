//
//  Queue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

struct Queue<Element> {
    fileprivate var dataArea: [Element]
    
    public init() {
        dataArea = [Element]()
    }
    
    public var all: [Element] { return dataArea }
    public var first: Element? { return dataArea.first }
    public var last: Element? { return dataArea.last }
    public var isEmpty: Bool { return dataArea.isEmpty }
    public var length: Int { return dataArea.count }
    
    @discardableResult
    public mutating func dequeue() -> Element? {
        if isEmpty { return nil }
        return dataArea.removeFirst()
    }
    
    public mutating func enqueue(_ newElement: Element) {
        dataArea.append(newElement)
    }
    
    public mutating func dequeueAll() -> [Element]? {
        let res = dataArea;
        dataArea.removeAll()
        return res
    }
    
    @inlinable
    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try dataArea.sort(by: areInIncreasingOrder)
    }
}


extension Queue : ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        dataArea = elements
    }
}
