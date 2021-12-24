//
//  Queue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

struct Queue<Element> {
    
    private var list = [Element]()
        
    var isEmpty: Bool { list.isEmpty }
    
    var length: Int { return list.count }
    
    @discardableResult
    mutating func dequeue() -> Element? {
        guard !list.isEmpty else { return nil }
        return list.removeFirst()
    }
    
    mutating func enqueue(_ newElement: Element) {
        list.append(newElement)
    }
    
    func peek() -> Element? {
        return list.first
    }
}

extension Queue : ExpressibleByArrayLiteral {
    
    typealias ArrayLiteralElement = Element
    
    init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        list.append(contentsOf: elements)
    }
    
    init(arrayLiteral elements: [Self.ArrayLiteralElement]) {
        list.append(contentsOf: elements)
    }
}

extension Queue {
    
    func forEach(_ body: (Element) throws -> Void) rethrows {
        try list.forEach(body)
    }
    
    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try list.sort(by: areInIncreasingOrder)
    }
}
