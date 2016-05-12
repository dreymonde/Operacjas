# Operations
**Operations** is an open-source implementation of concepts from [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/) talk.

`0.0.x` versions contains code directly from Apple's [sample project](https://developer.apple.com/sample-code/wwdc/2015/downloads/Advanced-NSOperations.zip).

## Usage

This section doesn't cover all the possibilites of **Operations**. For complete understanding of what's going on, please watch [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/) talk from Apple and read the source code (it's well commented by Apple).

#### Basic networking operation

```swift
import Foundation
import Operations

class DownloadSomethingOperation: Operation {
    
    let cacheFile: NSURL
    
    init(cacheFile: NSURL) {
        self.cacheFile = cacheFile
        super.init()
        self.name = "Download Something"
    }
    
    override func execute() {
        let url = NSURL(string: "https://example.com/file.json")!
        let task = NSURLSession.sharedSession().downloadTaskWithURL(url) { (savedFileURL, response, error) in
            if let savedFileURL = savedFileURL {
                self.downloadFinished(savedFileURL, response: response)
            } else if let error = error {
                self.downloadFailed(with: error)
            }
        }
        task.resume()
    }
    
}

extension DownloadSomethingOperation {
    
    func downloadFinished(savedFileURL: NSURL, response: NSURLResponse?) {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(cacheFile)
        } catch { }
        do {
            try fileManager.moveItemAtURL(savedFileURL, toURL: cacheFile)
            finish()
        } catch let error as NSError {
            finishWithError(error)
        }
    }
    
    func downloadFailed(with error: NSError) {
        finishWithError(error)
    }
    
}
```

```swift
let operationQueue = OperationQueue()
let download = DownloadSomethingOperation(cacheFile: cache)
operationQueue.addOperation(download)
```
