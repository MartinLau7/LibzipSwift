import XCTest
@testable import LibzipSwift

final class ZipArchiveTests: XCTestCase {
    
    var fileName: String {
        get {
            return "/Users/martin/Desktop/CodeSign/123new.zip"
        }
    }
    
    func testGetEntries() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        do {
            let zipArchive = try ZipArchive(path: fileName)
            defer {
                do {
                    try zipArchive.close()
                } catch { print("关闭 zip archive 失败")}
            }
            let entries = try zipArchive.getEntries()
            for entry in entries {
                print("entry name: \(entry.fileName)\n")
                print("entry posix: \(entry.posixPermission)\n")
                print("entry m_time: \(entry.modificationDate)")
                print("\n")
            }
        } catch ZipError.fileNotExist {
            print("文件不存在")
        } catch {
            print("Open Zip Error: ")
            print("\(error.localizedDescription)")
        }
    }
    
    func testNewZipArchive() {
        do {
            let zipArchive = try ZipArchive.createZip(path: "/Users/martin/Desktop/CodeSign/123new.zip")
            defer {
                do  {
                    try zipArchive.close()
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
            try zipArchive.addDirectory(dirName: "macOS")
            try zipArchive.addDirectory(dirName: "macOS/卍〆◈(*`ェ´*)")
            try zipArchive.addDirectory(dirName: "繁體简体 abc 123▦░▥▨▩┏◈〆卍")
            try zipArchive.addFile(file: "/Applications/网易有道词典.app/Contents/MacOS/网易有道词典", entryName: "macOS/wycd")
            try zipArchive.addFile(file: "/Users/martin/Desktop/CodeSign/programmer@2x.png", entryName: "test.png")
            
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func testExtractEntry() {
        do {
            let zipArchive = try ZipArchive(path: fileName)
            defer {
                do {
                    try zipArchive.close()
                } catch { print("关闭 zip archive 失败")}
            }
            let entries = try zipArchive.getEntries()
            for entry in entries {
//                if try entry.Extract(to: "/Users/martin/Desktop/CodeSign/123/\(entry.fileName)") { (item, progress) -> Bool in
//                    print("extracting item:\(item)\n\(progress)")
//                    return true
//                    } {
//                    print("success")
//                } else {
//                    print("fail")
//                }
                let result = try entry.extract(to: "/Users/martin/Desktop/CodeSign/123/\(entry.fileName)", nil)
                assert(result, "解压缩发生错误")
            }
            print("222")
        } catch ZipError.fileNotExist {
            print("文件不存在")
        } catch {
            print("Error : \(error.localizedDescription)")
        }
    }
    
    func testZipArchiveJudgment() {
        XCTAssertEqual(ZipArchive.isZipArchive(path: URL(fileURLWithPath: fileName)), true, "this is not a zip archive file")
//        assert(, "this is not a zip archive file")
    }
    
    func testOpenEntry2Data() {
        do {
            let zipArchive = try ZipArchive(path: fileName)
            defer {
                do {
                    try zipArchive.close()
                } catch { print("关闭 zip archive 失败")}
            }
            let entries = try zipArchive.getEntries()
            for entry in entries {
                if entry.isDirectory {
                    try FileManager.default.createDirectory(atPath: "/Users/MartinLau/Desktop/123/\(entry.fileName)", withIntermediateDirectories: true)
                } else {
                    var data: Data = Data()
                    if try entry.extract(to: &data) {
                        let filePath = URL(fileURLWithPath: "/Users/MartinLau/Desktop/123/\(entry.fileName)")
                        if !FileManager.default.fileExists(atPath: filePath.deletingLastPathComponent().path) {
                            try FileManager.default.createDirectory(atPath: filePath.deletingLastPathComponent().path, withIntermediateDirectories: true)
                        }
                        try data.write(to: filePath)
                    }
                }
            }
        } catch ZipError.fileNotExist {
            print("文件不存在")
        } catch {
            print("Open Zip Error: ")
            print("\(error.localizedDescription)")
        }
    }
    
    func testAvchiveOpreat() {
        if let zipArchive = try? ZipArchive(path: fileName) {
            defer {
                try? zipArchive.close()
            }
            
            // delete entry
//            XCTAssert(zipArchive.deleteEntry(entryName: "Info.plist"), zipArchive.error!.localizedDescription)
            
            // add folder
            if let index = try? zipArchive.addDirectory(dirName: "English🔣🅿️⌘") {
                XCTAssertEqual(index >= 0, true, zipArchive.error!.localizedDescription)
                return
            }
            
            // add file
            if let index = try? zipArchive.addFile(file: "/Applications/网易有道词典.app/Contents/MacOS/网易有道词典", entryName: "/macOS/网易有道词典", overwrite: true) {
                XCTAssertEqual(index >= 0, true, zipArchive.error!.localizedDescription)
            } else {
                print("=== \(zipArchive.error!.localizedDescription)")
            }
            
            // replace file
//            XCTAssert(zipArchive.replaceEntry(file: "/Users/martin/Desktop/CodeSign/programmer.webp", entryName: "Info.plist"), zipArchive.error!.localizedDescription)
            
        } else {
            
        }
    }
    
    static var allTests = [
        ("testZipArchiveJudgment", testZipArchiveJudgment),
        ("testGetEntries", testGetEntries),
        ("testOpenEntry2Data", testOpenEntry2Data),
        ("testExtractEntry", testExtractEntry),
        ("testZipArchiveJudgment", testZipArchiveJudgment),
        ("testAvchiveOpreat", testAvchiveOpreat),
    ]
}
