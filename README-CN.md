# LibzipSwift


### 关于

LibzipSwift 是基于 Libzip 封装用于macOS 和 iOS上对 zip 进行解压缩的 Framework套件. 
LibzipSwift 基于 [SwiftLibZip](https://github.com/SwiftZip/SwiftZip) 的一个独立分支
它透过 Libzip 提供一下功能：
- 列举 zip 中档案清单，包括概要的属性(其中优化了对中文编码的识别)
- 创建和修改 Zip 归档（包括删除和替换）
- 解压缩 Zip 归档（针对 Unix Zip 归档，保留Entry 的权限属性）

### 安装

Swift Package Manager

Once you have your Swift package set up, adding LibzipSwift as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift

dependencies: [
.package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-rc.3")
]

```

### 问题和建议
 
 如果你有问题，可以及时提出或做出对这个项目的代码贡献，感谢
 
 ### TODO
 
[] 完整的压缩函式
[] 对iOS 支持的完善
[] 对 unix 上的zip 归档保留更多属性
[] 完善单元测试
[] more

### License

- LibzipSwift : [See LICENSE (MIT)](https://github.com/MartinLau7/LibzipSwift/blob/master/LICENSE)

- Libzip: [See Libzip website](https://libzip.org/license/)
