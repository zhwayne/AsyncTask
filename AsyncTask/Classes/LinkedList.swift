//
//  LinkedList.swift
//  AsyncTask
//
//  Created by iya on 2021/12/22.
//

import Foundation

public class Node<T> {
    
    public var value: T
    
    public var next: Node<T>?
    
    public weak var previous: Node<T>?
    
    public init(value: T) {
        self.value = value
    }
}

extension Node: CustomStringConvertible {
    
    public var description: String {
        return "\(value)"
    }
}

public class LinkedList<T> {
    
    private var head: Node<T>?
    
    private var tail: Node<T>?
    
    private var count = 0
    
    public var isEmpty: Bool { head == nil }
    
    public var first: Node<T>? { head }
    
    public var last: Node<T>? { tail }
    
    public var length: Int { count }
    
    public init() {}
    
    public func append(value: T) {
        let node = Node(value: value)
        if let tail = tail {
            node.previous = tail
            tail.next = node
        } else {
            head = node
        }
        tail = node
        count += 1
    }
    
    @discardableResult
    public func remove(node: Node<T>) -> T {
        let previous = node.previous
        let next = node.next
        
        if let previous = previous {
            previous.next = next
        } else {
            head = next
        }
        next?.previous = previous
        
        if next == nil {
            tail = previous
        }
        
        node.previous = nil
        node.next = nil
        count -= 1
        return node.value
    }
    
    @discardableResult
    public func remove(at index: Int) -> T? {
        guard let node = node(at: index) else { return nil }
        return remove(node: node)
    }
    
    public func node(at index: Int) -> Node<T>? {
        guard index >= 0 else { return nil }
        var (idx, node) = (index, head)
        
        while node != nil {
            if idx == 0 { return node }
            idx -= 1
            node = node?.next
        }
        return node
    }
    
    public func forEach(_ body: (T) throws -> Void) rethrows {
        var node = head
        while node != nil {
            try body(node!.value)
            node = node?.next
        }
    }
    
    public func sort(by areInIncreasingOrder: (T, T) throws -> Bool) rethrows {
        // 暂未实现
    }
}

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        var text = "["
        var node = head
        
        while node != nil {
            text += "\(node!)"
            node = node!.next
            if node != nil { text += ", " }
        }
        return text + "]"
    }
}
