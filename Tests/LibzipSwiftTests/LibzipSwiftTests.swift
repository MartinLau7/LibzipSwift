import XCTest
@testable import LibzipSwift

final class LibzipSwiftTests: XCTestCase {
    
    let baseDirectory = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("TestData", isDirectory: true)
    
    var docArchive: String {
        get {
            return baseDirectory.appendingPathComponent("doc_archive.zip").path
        }
    }
    
    var winArchive: String {
        get {
            return baseDirectory.appendingPathComponent("win_archive.zip").path
        }
    }
    
    var unixArchive: String {
        get {
            return baseDirectory.appendingPathComponent("unix_archive.zip").path
        }
    }
    
    var encryptArchive: String {
        get {
            return baseDirectory.appendingPathComponent("encrypt_archive.zip").path
        }
    }
    
    func testNewArchive() {
        let newarchiveURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newArchive.zip")
        do {
            if FileManager.default.fileExists(atPath: newarchiveURL.path) {
                try FileManager.default.removeItem(at: newarchiveURL)
            }
            let archive = try ZipArchive.createZip(url: newarchiveURL)
            defer {
                XCTAssertNoThrow(try archive.close())
            }
            XCTAssertNoThrow(try archive.addDirectory(dirName: "繁體中文") >= 0)
            XCTAssertNoThrow(try archive.addDirectory(dirName: "简体中文") >= 0)
            XCTAssertNoThrow(try archive.addDirectory(dirName: "english") >= 0)
            XCTAssertNoThrow(try archive.addDirectory(dirName: "あいかきサコセゅゑшнлкюяыь") >= 0)
            XCTAssertNoThrow(try archive.addFile(url: baseDirectory.appendingPathComponent("時間时间Time😀¹²①②.txt")) >= 0)
            XCTAssertNoThrow(try archive.addFile(url: baseDirectory.appendingPathComponent("時間时间Time😀¹²①②.txt"), entryName: "folder/時間时间Time😀¹²①②.txt") >= 0)
            archive.registerProgressCallback { pg in
                print("==> \(pg)%")
            }
        } catch {
             XCTFail(error.localizedDescription)
        }
    }
    
    func testIsZipArchive() {
        let archives: [String] = [docArchive, winArchive, unixArchive, encryptArchive]
        for archive in archives {
            do {
                let iszip = try ZipArchive.isZipArchive(at: URL(fileURLWithPath: archive))
                XCTAssertEqual(iszip, true, "\(archive) is not a zip archive file")
            } catch {
                XCTFail("\(error.localizedDescription)")
            }
        }
    }
    
    func testListEntries() {
        let archives = [docArchive: "", winArchive: "", unixArchive: "", encryptArchive: "libzip"]
        let expectedDict = [
            docArchive: ["programmer.png", "繁體中文/時間/", "繁體中文/文本檔案.txt", "简体中文/新建文本文档.txt"],
            winArchive: ["programmer.png", "вｙe вｙЁəiεə.txt", "ㅂㄶㄵㅁㅀもぬに.txt", "简体中文/", "简体中文/新建文本文档.txt", "繁體中文/", "繁體中文/文本檔案.txt", "繁體中文/時間/"],
            unixArchive: ["test.png", "macOS/", "macOS/print.sh", "macOS/卍〆◈(*`ェ´*)/", "English🔣🅿️⌘/", "繁體简体 abc 123▦░▥▨▩┏◈〆卍/"],
            encryptArchive: ["Test File C.m4a", "Test File A.txt", "Test File B.jpg"]
        ]
        for (archive, password) in archives {
            do {
                let zipArchive = try ZipArchive(path: archive)
                defer {
                    try? zipArchive.close()
                }
                if !password.isEmpty {
                    try zipArchive.setDefaultPassword(password)
                }
                if let entries = try? zipArchive.getEntries() {
                    let expected = expectedDict[archive]
                    let actual = entries.map { $0.fileName }
                    XCTAssertEqual(actual, expected)
                }
            } catch {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }
    
    func testArchiveExtract() {
        let archives = [docArchive: "", winArchive: "", unixArchive: "", encryptArchive: "123"]
        for (archive, password) in archives {
            do {
                let zipArchive = try ZipArchive(path: archive)
                defer {
                    XCTAssertNoThrow(try zipArchive.close())
                }
                if !password.isEmpty {
                    try zipArchive.setDefaultPassword(password)
                }
                let extResult = try zipArchive.extractAll(to: FileManager.default.currentDirectoryPath, overwrite: true, { (entryName, entryProgress, totalProgress) -> Bool in
                    print("\(entryName) extracting...\(totalProgress)")
                    return true
                })
                XCTAssertEqual(extResult, true, zipArchive.error!.localizedDescription)
            } catch {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }
    
    func testUpdateEntry() {
        let tmp = unixArchive.replacingOccurrences(of: URL(fileURLWithPath: unixArchive).lastPathComponent, with: "test.zip")
        do {
            if FileManager.default.fileExists(atPath: tmp) {
                try FileManager.default.removeItem(atPath: tmp)
            }
            try FileManager.default.copyItem(atPath: unixArchive, toPath: tmp)
            let zipArchive = try ZipArchive(path: tmp)
            defer {
                do {
                    try zipArchive.close()
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
            var result = zipArchive.replaceEntry(file: baseDirectory.appendingPathComponent("時間时间Time😀¹²①②.txt").path, entryName: "macOS/print.sh")
            if !result {
                XCTAssert(result, "update file error")
            }
            result = try zipArchive.addFile(file: baseDirectory.appendingPathComponent("時間时间Time😀¹²①②.txt").path) >= 0
            XCTAssert(result, "update file error")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRemoveEntry() {
        let tmp = unixArchive.replacingOccurrences(of: URL(fileURLWithPath: unixArchive).lastPathComponent, with: "test.zip")
        do {
            if FileManager.default.fileExists(atPath: tmp) {
                try FileManager.default.removeItem(atPath: tmp)
            }
            try FileManager.default.copyItem(atPath: unixArchive, toPath: tmp)
            let zipArchive = try ZipArchive(path: tmp)
            let entries = try zipArchive.getEntries()
            XCTAssert(zipArchive.deleteEntry(entryName: entries.first!.fileName), "delete entry fail")
            try zipArchive.close()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testReameEntry() {
        let tmp = unixArchive.replacingOccurrences(of: URL(fileURLWithPath: unixArchive).lastPathComponent, with: "test.zip")
        do {
            if FileManager.default.fileExists(atPath: tmp) {
                try FileManager.default.removeItem(atPath: tmp)
            }
            try FileManager.default.copyItem(atPath: unixArchive, toPath: tmp)
            let zipArchive = try ZipArchive(path: tmp)
            let entries = try zipArchive.getEntries()
            XCTAssert(entries.first!.rename(name: "123.ppp"), "rename entry fail")
            try zipArchive.close()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    static var allTests = [
        ("testIsZipArchive",   testIsZipArchive),
        ("testNewArchive",     testNewArchive),
        ("testListEntries",    testListEntries),
        ("testArchiveExtract", testArchiveExtract),
        ("testUpdateEntry",    testUpdateEntry),
        ("testRemoveEntry",    testRemoveEntry),
        ("testReameEntry",     testReameEntry),
    ]
}
