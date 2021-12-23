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
    
    /// 头节点
    private var head: Node<T>?
    
    /// 为节点
    private var tail: Node<T>?
    
    private var nodeCount = 0
    
    /// 链表是否为空
    public var isEmpty: Bool { head == nil }
    
    /// 链表第一个节点（头节点）
    public var first: Node<T>? { head }
    
    /// 链表最后一个节点（尾节点）
    public var last: Node<T>? { tail }
    
    /// 链表的长度
    public var length: Int {
        if nodeCount >= 0 { return nodeCount }
        var (idx, node) = (0, head)
        while node != nil { idx += 1; node = node?.next }
        nodeCount = idx
        return nodeCount
    }
    
    public init() {}
    
    /// 向链表中添加一个元素
    ///
    /// 添加的元素自动被包裹在节点中
    /// - Parameter value: 元素值
    public func append(value: T) {
        defer { nodeCount += 1 }
        let newNode = Node(value: value)
        if let tail = tail {
            newNode.previous = tail
            tail.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }
    
    /// 在指定位置插入元素
    ///
    /// 添加的元素自动被包裹在节点中
    /// - Parameters:
    ///   - value: 元素值
    ///   - index: 位置下标
    public func insert(value: T, at index: Int) {
        guard index >= 0 && index < length else {
            fatalError("index \(index) out of bounds.")
        }
        
        let newNode = Node(value: value)
        guard let node = node(at: index) else {
            head = newNode
            return
        }
        newNode.next = node
        node.previous = newNode
        
        let previous = node.previous
        if let previous = previous {
            newNode.previous = previous
            previous.next = newNode
        } else {
            head = newNode
        }
    }
    
    /// 删除结点
    ///
    /// 节点必须为链表中的节点
    /// - Parameter node: 节点
    /// - Returns: 节点中包含的值
    private func remove(node: Node<T>) -> T {
        defer { nodeCount -= 1 }
        
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
        return node.value
    }
    
    @discardableResult
    /// 删除某个位置的节点
    /// - Parameter index: 位置下标
    /// - Returns: 节点中包含的值
    public func remove(at index: Int) -> T? {
        guard let node = node(at: index) else { return nil }
        defer { nodeCount -= 1 }
        return remove(node: node)
    }
    
    /// 获取制定位置的节点
    /// - Parameter index: 位置下标
    /// - Returns: 目标节点
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
    
    /// 从头至尾遍历链表
    /// - Parameter body: 执行闭包
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
