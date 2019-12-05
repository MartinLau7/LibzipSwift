import XCTest
@testable import LibzipSwift

final class LibzipSwiftTests: XCTestCase {
    
    let baseDirectory = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("TestData", isDirectory: true)
    var docArchive: String {
        get {
            return baseDirectory.appendingPathComponent("doc_Archive.zip").path
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
            return baseDirectory.appendingPathComponent("encrypt_Archive.zip").path
        }
    }
    
    func testNewArchive() {
        let newarchiveURL = baseDirectory.appendingPathComponent("new_Archive.zip")
        do {
            if FileManager.default.fileExists(atPath: newarchiveURL.path) {
                try FileManager.default.removeItem(at: newarchiveURL)
            }
            let archive = try ZipArchive(url: newarchiveURL, mode: [.create, .checkConsistency])
            defer {
                XCTAssertNoThrow(try archive.close())
            }
            XCTAssertNoThrow(try archive.addDirectory(dirName: "繁體中文") >= 0)
            XCTAssertNoThrow(try archive.addDirectory(dirName: "简体中文") >= 0)
            XCTAssertNoThrow(try archive.addDirectory(dirName: "english") >= 0)
            XCTAssertNoThrow(try archive.addDirectory(dirName: "あいかきサコセゅゑшнлкюяыь") >= 0)
            XCTAssertNoThrow(try archive.addFile(url: baseDirectory.appendingPathComponent("時間时间Time😀¹²①②.txt")) >= 0)
            XCTAssertNoThrow(try archive.addFile(url: baseDirectory.appendingPathComponent("時間时间Time😀¹²①②.txt"), entryName: "folder/時間时间Time😀¹²①②.txt") >= 0)
        } catch {
             XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testIsZipArchive() {
        let archives: [String] = [docArchive, winArchive, unixArchive, encryptArchive]
        for archive in archives {
            XCTAssertEqual(ZipArchive.isZipArchive(path: URL(fileURLWithPath: archive)), true, "\(archive) this is not a zip archive file")
        }
    }
    
    func testListEntries() {
        let archives = [docArchive: "", winArchive: "", unixArchive: "", encryptArchive: "libzip"]
        let expectedDict = [
            docArchive: ["programmer.png", "繁體中文/時間/", "繁體中文/文本檔案.txt", "简体中文/新建文本文档.txt"],
            winArchive: ["programmer.png", "вｙe вｙЁəiεə.txt", "ㅂㄶㄵㅁㅀもぬに.txt", "简体中文/", "简体中文/新建文本文档.txt", "繁體中文/", "繁體中文/文本檔案.txt", "繁體中文/時間/"],
            unixArchive: ["test.png", "macOS/", "macOS/print.sh", "macOS/卍〆◈(*`ェ´*)/", "English🔣🅿️⌘/", "繁體简体 abc 123▦░▥▨▩┏◈〆卍/"],
            encryptArchive: ["programmer.webp"]
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
        let archives = [docArchive: "", winArchive: "", unixArchive: "", encryptArchive: "libzip"]
        for (archive, password) in archives {
            do {
                let zipArchive = try ZipArchive(path: archive)
                defer {
                    XCTAssertNoThrow(try zipArchive.close())
                }
                if !password.isEmpty {
                    try zipArchive.setDefaultPassword(password)
                }
                let extResult = try zipArchive.extractAll(to: FileManager.default.currentDirectoryPath, overwrite: true) { (entryName, progress) -> Bool in
                    print("\(entryName) extracting...\(progress)")
                    return true
                }
                XCTAssertEqual(extResult, true, zipArchive.error!.localizedDescription)
            } catch {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }
    
    func testUpdateEntry() {
        
    }
    
    func testRemoveEntry() {
        
    }
    
    func testReameEntry() {
        
    }
    
    func testEncryptArchive() {
        do {
            let archvies: [String] = [docArchive, winArchive, unixArchive]
            for archive in archvies {
                let zipArchive = try ZipArchive(path: archive)
                defer {
                    XCTAssertNoThrow(try zipArchive.close())
                }
                let extResult = try zipArchive.extractAll(to: FileManager.default.currentDirectoryPath, overwrite: true) { (entryName, progress) -> Bool in
                    print("\(entryName) extracting...\(progress)")
                    return true
                }
                XCTAssertEqual(extResult, true, zipArchive.error!.localizedDescription)
            }
        } catch {
            XCTAssert(false, error.localizedDescription)
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
