# AsyncTask

[![CI Status](https://img.shields.io/travis/iya/AsyncTask.svg?style=flat)](https://travis-ci.org/iya/AsyncTask)
[![Version](https://img.shields.io/cocoapods/v/AsyncTask.svg?style=flat)](https://cocoapods.org/pods/AsyncTask)
[![License](https://img.shields.io/cocoapods/l/AsyncTask.svg?style=flat)](https://cocoapods.org/pods/AsyncTask)
[![Platform](https://img.shields.io/cocoapods/p/AsyncTask.svg?style=flat)](https://cocoapods.org/pods/AsyncTask)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

```swift
let tasks = (0..<10).map { idx -> AsyncTask in
  return AsyncTask(priority: .custom(idx)) { task in
    print("t\(idx) start")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      print("t\(idx) end")  
      task.finish()
    }
  }
}

queue.add(tasks: tasks)
```

## Requirements

## Installation

AsyncTask is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AsyncTask'
```

## Author

iya, mrzhwayne@163.com

## License

AsyncTask is available under the MIT license. See the LICENSE file for more info.
