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
        var rawValue: Int = 0
        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let background    = Self(rawValue: 0)
        public static let low           = Self(rawValue: 250)
        public static let `default`     = Self(rawValue: 500)
        public static let hight         = Self(rawValue: 750)
        public static let required      = Self(rawValue: 1000)
    }
}

extension AsyncTask.Priority {
    
    public static func + (lhs: Self, rhs: Int) -> Self {
        let priority = Self(rawValue: lhs.rawValue + rhs)
        return min(priority, .required)
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
