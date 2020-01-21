# LibzipSwift

[中文](https://github.com/MartinLau7/LibzipSwift/blob/master/README-CN.md)

### About

LibzipSwift is a framework suite based on Libzip package for decompressing zip on macOS and iOS.

LibzipSwift is a separate branch based on [SwiftLibZip](https://github.com/SwiftZip/SwiftZip), 
It provides the following functions via Libzip: 

- Enumerate the list of archives in the zip, including the summary attributes (which optimizes the recognition of Chinese encoding)
- Create and modify Zip archives (including deletion and replacement)
- Unzip the Zip archive (for Unix Zip archives, retain Entry's permission attributes)

### Installation

#### Swift Package Manager

Once you have your Swift package set up, adding LibzipSwift as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift

dependencies: [
    .package(url: "https://github.com/MartinLau7/LibzipSwift.git", from: "0.1")
]

```


### Instructions

> Open and read

```swift
do {
    let archive = try ZipArchive(url: newarchiveURL)
    defer {
        try archive.close()
    }
    if let entries = try? zipArchive.getEntries() {
        // check the entries
    }
    // You can modify and add entries in here
    ...

} catch {
     // Handle errors here
    print("\(Handle errors here)")
}
```

> create zip archive

```swift
do {
    let archive = try ZipArchive(url: newarchiveURL, mode: [.create, .checkConsistency])
    defer {
        try archive.close()
    }
    try archive.addDirectory(dirName: "the folder")
    try archive.addFile(path: "/xx/xx/you.file", entryName: "entry name is Optional param") >= 0)
} catch {
     // Handle errors here
    print("\(Handle errors here)")
}
```

When you want to undo the changes, you can add discardChanged: false to the close method. like :
`try archive.close(discardChanged: false)`

### Question & Suggestions
 
 If you have questions, you can promptly make or contribute to the code of this project, thanks
 
### TODO
 
- [ ] Complete compression function

- [ ] Improved iOS support

- [ ] Preserve more attributes for zip archives on unix

- [ ] Improve unit testing

- [ ] more
 
 
### License
 
- LibzipSwift : [See LICENSE (MIT)](https://github.com/MartinLau7/LibzipSwift/blob/master/LICENSE)

- Libzip: [See Libzip website](https://libzip.org/license/)
