//
//  AsyncTask+Priority.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public extension AsyncTask {
    
    /// 任务优先级
    struct Priority {
        fileprivate var rawValue: Int = 0
        fileprivate init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let background      = Self(rawValue: 0)
        public static let low             = Self(rawValue: 250)
        public static let `default`       = Self(rawValue: 500)
        public static let hight           = Self(rawValue: 750)
        public static let userInteractive = Self(rawValue: 1000)
    }
}

extension AsyncTask.Priority {
    
    public static func + (lhs: Self, rhs: Int) -> Self {
        let priority = Self(rawValue: lhs.rawValue + rhs)
        return min(priority, .userInteractive)
    }
    
    public static func - (lhs: Self, rhs: Int) -> Self {
        let priority = Self(rawValue: lhs.rawValue - rhs)
        return max(priority, .background)
    }
}

extension AsyncTask.Priority: Comparable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}
