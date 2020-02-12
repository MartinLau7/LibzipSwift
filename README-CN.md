# LibzipSwift



### 关于

LibzipSwift 是基于 Libzip 封装用于macOS 和 iOS上对 zip 进行解压缩的 Framework套件. 

LibzipSwift 基于 [SwiftLibZip](https://github.com/SwiftZip/SwiftZip) 的一个独立分支,它透过Libzip 的封装提供一下功能：

- 列举 zip 中档案清单，包括概要的属性(其中优化了对中文编码的识别)
- 创建和修改 Zip 归档（包括删除和替换）
- 解压缩 Zip 归档（针对 Unix Zip 归档，保留Entry 的权限属性）

### 安装

#### Swift Package Manager

Once you have your Swift package set up, adding LibzipSwift as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift

dependencies: [
.package(url: "https://github.com/MartinLau7/LibzipSwift.git", from: "0.1")
]

```

### 使用方法

> 访问 Zip Archive File

```swift
do {
let archive = try ZipArchive(url: newarchiveURL)
defer {
try archive.close()
}
if let entries = try? zipArchive.getEntries() {
// 遍历和操作  entries
}
// 你也可以对 zipArchive进行修改和新增
...

} catch {
// Handle errors here
print("\(Handle errors here)")
}
```

> 创新新的 Zip Archive 文件

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

如果你想撤销修改，可以在 Close 函数添加参数进行撤销 :
`try archive.close(discardChanged: false)`

### 问题和建议

如果你有问题，可以及时提出或做出对这个项目的代码贡献，感谢

### TODO

- [x] ~~完整的压缩函式~~
- [ ] 对iOS 支持的完善
- [ ] 对 unix 上的zip 归档保留更多属性
- [ ] 完善单元测试
- [ ] more

### License

- LibzipSwift : [See LICENSE (MIT)](https://github.com/MartinLau7/LibzipSwift/blob/master/LICENSE)

- Libzip: [See Libzip website](https://libzip.org/license/)
