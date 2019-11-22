# LibzipSwift

[中文](https://github.com/MartinLau7/LibzipSwift/blob/master/README-CN.md)

### About

LibzipSwift is a framework suite based on Libzip package for decompressing zip on macOS and iOS.
LibzipSwift is a separate branch based on [SwiftLibZip](https://github.com/SwiftZip/SwiftZip) 
It provides the following functions via Libzip:
-Enumerate the list of archives in the zip, including the summary attributes (which optimizes the recognition of Chinese encoding)
-Create and modify Zip archives (including deletion and replacement)
-Unzip the Zip archive (for Unix Zip archives, retain Entry's permission attributes)

### Installation

Swift Package Manager

Once you have your Swift package set up, adding LibzipSwift as a dependency is as easy as adding it to the dependencies value of your Package.swift.

`` `swift

dependencies: [
.package (url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-rc.3")
]

`` `

### Question & Suggestions
 
 If you have questions, you can promptly make or contribute to the code of this project, thanks
 
 ### TODO
 
 [] Complete compression function
 [] Improved iOS support
 [] Preserve more attributes for zip archives on unix
 [] Improve unit testing
 [] more
 
 
 ### License
 
 -LibzipSwift: [See LICENSE (MIT)] (https://github.com/MartinLau7/LibzipSwift/blob/master/LICENSE)
 
 -Libzip: [See Libzip website] (https://libzip.org/license/)
