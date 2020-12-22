//
//  ZipArchive.swift
//
//
//  Created by MartinLau on 2019/11/22.
//

import Foundation
import libzip

public final class ZipArchive: ZipErrorHandler {
    private var compressionCallback: ((Double) -> Void)?
    private var compressionMethod: CompressionMethod = .default
    private var compressionLevel: CompressionLevel = .fastest
    
    internal var archivePointer: OpaquePointer!
    
    // MARK: - struct
    
    public struct LocateFlags: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public static let none = LocateFlags([])
        public static let caseInsensitive = LocateFlags(rawValue: ZIP_FL_NOCASE)
        public static let ignoreDirectory = LocateFlags(rawValue: ZIP_FL_NODIR)
    }
    
    // MARK: - property
    
    internal var error: ZipError? {
        return .zipError(zip_get_error(archivePointer).pointee)
    }
    
    // MARK: - static
    
    /// check the file is zip archive
    /// - Parameter url: the file url
    public static func isZipArchive(at url: URL) throws -> Bool {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer {
            fileHandle.closeFile()
        }
        let data = fileHandle.readData(ofLength: 4)
        if data.count < 4 {
            return false
        }
        if data[0] != 0x50 || data[1] != 0x4B {
            return false
        }
        // Check for standard Zip File
        if data[0] != 0x03 || data[1] != 0x04 {
            return true
        }
        // Check for empty Zip File
        if data[0] != 0x05 || data[1] != 0x06 {
            return true
        }
        // Check for spanning Zip File
        if data[0] != 0x07 || data[1] != 0x08 {
            return true
        }
        return false
    }
    
    /// check the file is zip archive
    /// - Parameter path: the file path
    public static func isZipArchive(atPath path: String) -> Bool {
        if let fileHandle = FileHandle(forReadingAtPath: path) {
            defer {
                fileHandle.closeFile()
            }
            let data = fileHandle.readData(ofLength: 4)
            if data.count < 4 {
                return false
            }
            if data[0] != 0x50 || data[1] != 0x4B {
                return false
            }
            // Check for standard Zip File
            if data[0] != 0x03 || data[1] != 0x04 {
                return true
            }
            // Check for empty Zip File
            if data[0] != 0x05 || data[1] != 0x06 {
                return true
            }
            // Check for spanning Zip File
            if data[0] != 0x07 || data[1] != 0x08 {
                return true
            }
        }
        return false
    }
    
    public static func createZip(path: String) throws -> ZipArchive {
        return try ZipArchive(path: path, mode: [.create, .checkConsistency])
    }
    
    public static func createZip(url: URL) throws -> ZipArchive {
        return try ZipArchive(url: url, mode: [.create, .checkConsistency])
    }
    
    // MARK: - init / open
    
    deinit {
        if let handle = archivePointer {
            zip_discard(handle)
        }
    }
    
    public init(path: String, mode: [OpenMode] = [.none]) throws {
        if !mode.contains(where: { mode -> Bool in
            if mode == .create {
                return true
            }
            return false
        }) {
            if !FileManager.default.fileExists(atPath: path) {
                throw ZipError.fileNotExist
            }
        }
        
        var falgs: OpenMode = OpenMode(rawValue: 0)
        mode.forEach {
            falgs = OpenMode(rawValue: falgs.rawValue | $0.rawValue)
        }
        var status: Int32 = ZIP_ER_OK
        let handle = path.withCString { path in
            zip_open(path, falgs.rawValue, &status)
        }
        
        try checkZipError(status)
        archivePointer = try handle.unwrapped()
    }
    
    public init(url: URL, mode: [OpenMode] = [.none]) throws {
        if !mode.contains(where: { mode -> Bool in
            if mode == .create {
                return true
            }
            return false
        }) {
            if !FileManager.default.fileExists(atPath: url.path) {
                throw ZipError.fileNotExist
            }
        }
        
        var falgs: OpenMode = OpenMode(rawValue: Int32(0))
        mode.forEach { item in
            falgs = OpenMode(rawValue: falgs.rawValue | item.rawValue)
        }
        var status: Int32 = ZIP_ER_OK
        let handle: OpaquePointer? = try url.withUnsafeFileSystemRepresentation { path in
            if let path = path {
                return zip_open(path, falgs.rawValue, &status)
            } else {
                throw ZipError.unsupportedURL
            }
        }
        
        try checkZipError(status)
        archivePointer = try handle.unwrapped()
    }
    
    public func close(discardChanged: Bool = false) throws {
        if discardChanged {
            zip_discard(archivePointer)
        } else {
            zip_close(archivePointer)
        }
        archivePointer = nil
    }
    
    // MARK: - password handling
    
    public func setDefaultPassword(_ password: String) throws {
        try password.withCString { password in
            _ = try checkZipError(zip_set_default_password(archivePointer, password))
        }
    }
    
    // MARK: - comments
    
    public func getComment(encoding: ZipEncoding = .guess, condition: Condition = .last) throws -> String {
        return try String(cString: checkZipResult(zip_get_archive_comment(archivePointer, nil, encoding.rawValue | condition.rawValue)))
    }
    
    public func setComment(comment: String) throws {
        try comment.withCString { comment in
            _ = try checkZipResult(zip_set_archive_comment(archivePointer, comment, zipCast(strlen(comment))))
        }
    }
    
    public func deleteComment() throws {
        try checkZipResult(zip_set_archive_comment(archivePointer, nil, 0))
    }
    
    // MARK: - entry
    
    private func getEntryCount(condition: Condition = .last) throws -> Int {
        return try zipCast(checkZipResult(zip_get_num_entries(archivePointer, condition.rawValue)))
    }
    
    public func getEntries() throws -> [ZipEntry] {
        let count = try getEntryCount()
        var zipentries: [ZipEntry] = Array()
        for idx in 0 ..< count {
            var stat = zip_stat()
            try checkZipResult(zip_stat_index(archivePointer, zip_uint64_t(idx), Condition.last.rawValue, &stat))
            let entry = ZipEntry(archive: self, stat: stat)
            zipentries.append(entry)
        }
        return zipentries
    }
    
    private func lookupEntry(_ entryName: String, _ caseSensitive: Bool) -> Int64 {
        guard !entryName.isEmpty else {
            return -1
        }
        return entryName.withCString { entryName in
            if let index = try? checkZipResult(zip_name_locate(archivePointer, entryName, caseSensitive ? LocateFlags.none.rawValue : LocateFlags.caseInsensitive.rawValue)) {
                return index
            }
            return -1
        }
    }
    
    public func readEntry(from index: UInt64) -> ZipEntry? {
        var stat = zip_stat()
        if let index = try? checkZipResult(zip_stat_index(archivePointer, index, Condition.last.rawValue, &stat)) {
            if index >= 0 {
                return ZipEntry(archive: self, stat: stat)
            }
        }
        return nil
    }
    
    public func readEntry(entryName: String, caseSensitive: Bool = false) -> ZipEntry? {
        guard !entryName.isEmpty else {
            return nil
        }
        let index = lookupEntry(entryName, caseSensitive)
        if index >= 0 {
            return readEntry(from: UInt64(index))
        }
        return nil
    }
    
    public func containsEntry(entryName: String, caseSensitive: Bool = false) -> Bool {
        return lookupEntry(entryName, caseSensitive) >= 0
    }
    
    public func containsEntry(entryName: String, caseSensitive: Bool = false, index: inout UInt64) -> Bool {
        let idx = lookupEntry(entryName, caseSensitive)
        if idx >= 0 {
            index = UInt64(idx)
            return true
        }
        return false
    }
    
    public func deleteEntry(index: UInt64) -> Bool {
        return checkIsSuccess(zip_delete(archivePointer, index))
    }
    
    public func deleteEntry(entryName: String, caseSensitive: Bool = false) -> Bool {
        guard !entryName.isEmpty else {
            return false
        }
        let index = lookupEntry(entryName, caseSensitive)
        if index >= 0 {
            return deleteEntry(index: UInt64(index))
        }
        return false
    }
    
    /// add file on zip
    /// - Parameters:
    ///   - file: the file path
    ///   - entryName: the entry name
    ///   - overwrite: overwrite
    @discardableResult
    public func addFile(file: String, entryName: String = "", overwrite: Bool = false) throws -> Int64 {
        var entryFullName = entryName
        if entryFullName.isEmpty {
            entryFullName = URL(fileURLWithPath: file).lastPathComponent
        }
        if let zipSource = try? ZipSource(fileName: file) {
            var posix: UInt32 = 0
            if let attributes = try? FileManager.default.attributesOfItem(atPath: file) {
                posix = attributes[.posixPermissions] as! UInt32
            }
            let result = try entryFullName.withCString { entryFullName -> Int64 in
                var flags = ZIP_FL_ENC_UTF_8
                if overwrite {
                    flags |= ZIP_FL_OVERWRITE
                }
                return try zipCast(checkZipResult(zip_file_add(archivePointer, entryFullName, zipSource.sourcePointer, flags)))
            }
            zipSource.keep()
            if result >= 0 {
                let permissionsMask: UInt32 = (posix & 0o777) << 16
                if let entry = readEntry(from: UInt64(result)) {
                    var external_fa = entry.externalAttributes.attributes
                    external_fa |= permissionsMask
                    try entry.setExternalAttributes(operatingSystem: .unix, attributes: external_fa)
                    try entry.setCompression(method: compressionMethod, flags: compressionLevel)
                }
            }
            return result
        }
        return -1
    }
    
    /// add file on zip
    /// - Parameters:
    ///   - url: the file url
    ///   - entryName: entry name
    ///   - override: override
    @discardableResult
    public func addFile(url: URL, entryName: String = "", overwrite: Bool = false) throws -> Int64 {
        return try addFile(file: url.path, entryName: entryName, overwrite: overwrite)
    }
    
    /// add directory to zip archive
    /// - Parameter dirName: **the directory name**
    @discardableResult
    public func addDirectory(dirName: String) throws -> UInt64 {
        return try dirName.withCString { dirName in
            try zipCast(checkZipResult(zip_dir_add(archivePointer, dirName, ZipEncoding.utf8.rawValue)))
        }
    }
    
    public func replaceEntry(file: String, entryName: String, caseSensitive: Bool = false) -> Bool {
        if let zipSource = try? ZipSource(fileName: file) {
            if let entry = readEntry(entryName: entryName, caseSensitive: caseSensitive) {
                if (try? entry.replace(source: zipSource)) != nil {
                    return true
                }
            }
        }
        return false
    }
    
    public func replaceEntry(file: String, entryIndex: UInt64) -> Bool {
        if FileManager.default.fileExists(atPath: file) {
            if let zipSource = try? ZipSource(fileName: file) {
                if let entry = readEntry(from: entryIndex) {
                    return ((try? entry.replace(source: zipSource)) != nil)
                }
            }
        }
        return false
    }
    
    public func setCompression(cm: CompressionMethod, cl: CompressionLevel) {
        compressionMethod = cm
        compressionLevel = cl
    }
    
    /// extract all entries to folder.
    /// - Parameters:
    ///   - dir: the dst folder.
    ///   - passwrod: the password.
    ///   - overwrite: need overwrite.
    ///   - closure: the progress block.
    public func extractAll(to dir: String, passwrod: String = "", overwrite: Bool = false, _ closure: ((_ entryName: String, _ entryProgress: Double, _ totalProgress: Double) -> Bool)?) throws -> Bool {
        let entries = try getEntries()
        for (idx, entry) in entries.enumerated() {
            let totalProgress = Double(idx) / Double(entries.count)
            let extPath = URL(fileURLWithPath: dir).appendingPathComponent(entry.fileName).path
            let result = try entry.extract(to: extPath, password: passwrod, overwrite: overwrite) { (entryName, entryProgress) -> Bool in
                if let cb = closure {
                    return cb(entryName, entryProgress, totalProgress)
                }
                return true
            }
            if !result {
                return result
            }
        }
        if let cb = closure {
            _ = cb("", 0, 1.0)
        }
        return true
    }
    
    // MARK: - Revert Changes
    
    /// undo global changes to zip archive
    public func unchangeGlobals() throws {
        try checkZipResult(zip_unchange_archive(archivePointer))
    }
    
    /// undo all changes in a zip archive
    public func unchangeAll() throws {
        try checkZipResult(zip_unchange_all(archivePointer))
    }
    
    // MARK: - callback
    
    /// provide updates during zip_close
    /// - Parameter callback: callback
    public func registerProgressCallback(_ callback: @escaping (Double) -> Void) {
        compressionCallback = callback
        let userData = UnsafeMutableRawPointer(mutating: Unmanaged<ZipArchive>.passUnretained(self).toOpaque())
        zip_register_progress_callback_with_state(archivePointer, 0.1, { _, progress, udPtr in
            if let udPtr = udPtr {
                let archiveUd = Unmanaged<ZipArchive>.fromOpaque(udPtr).takeUnretainedValue()
                archiveUd.compressionCallback?(progress)
            }
        }, nil, userData)
    }
}
