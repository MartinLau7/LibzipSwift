import libzip
import Foundation

public final class ZipEntry: ZipErrorHandler {
    
    let archive: ZipArchive
    let stat: zip_stat
    
    private let vaild: zip_uint64_t
    //    private let localExtraFieldsCount: CShort
    //    private let centralExtraFieldsCount: CShort
    
    // MARK: - property
    
    public let CRC: UInt
    
    public let index: zip_uint64_t
    
    public let fileName: String
    
    public let isDirectory: Bool
    
    public let modificationDate: Date
    
    public let isSymbolicLink: Bool
    
    public let posixPermission: UInt16
    
    public let compressedSize: UInt64
    
    public let uncompressedSize: UInt64
    
    public let compressionMethod: CompressionMethod
    
    public let compressionLevel: CompressionLevel
    
    public let encryptionMethod: EncryptionMethod
    
    public let externalAttributes: ExternalAttributes
    
    public var error: ZipError? {
        return archive.error
    }
    
    // MARK: - static function
    
    fileprivate struct FileType: RawRepresentable {
        
        public let rawValue: mode_t
        public init(rawValue: mode_t) {
            self.rawValue = rawValue
        }
        
        fileprivate static let IFO = FileType(rawValue: S_IFIFO)
        fileprivate static let CHR = FileType(rawValue: S_IFCHR)
        fileprivate static let DIR = FileType(rawValue: S_IFDIR)
        fileprivate static let BLK = FileType(rawValue: S_IFBLK)
        fileprivate static let REG = FileType(rawValue: S_IFREG)
        fileprivate static let LNK = FileType(rawValue: S_IFLNK)
        fileprivate static let SOCK = FileType(rawValue: S_IFSOCK)
    }
    
    private static func getCompressionlevel(stat: zip_stat) -> CompressionLevel {
        var level:CompressionLevel = .default
        if stat.comp_method != 0 {
            switch (((stat.flags & 0x6) / 2)) {
                case 0:
                    level = .default
                case 1:
                    level = .best
                default:
                    level = .fastest
            }
        }
        return level
    }
    
    private static func itemFileType(_ attributes: UInt32) -> FileType {
        return FileType(rawValue: (S_IFMT & UInt16((attributes >> 16))))
    }
    
    private static func itemIsDOSDirectory(_ attributes: UInt32) -> Bool {
        return 0x01 & (attributes >> 4) != 0;
    }
    
    private static func itemIsDirectory(_ externalAttributes: ExternalAttributes) -> Bool {
        if externalAttributes.operatingSystem == .Dos || externalAttributes.operatingSystem == .WINDOWS_NTFS {
            return ZipEntry.itemIsDOSDirectory(externalAttributes.attributes)
        }
        return itemFileType(externalAttributes.attributes) == .DIR
    }
    
    private static func itemPermissions(_ attributes: UInt32) -> UInt16 {
        let permissionsMask = S_IRWXU | S_IRWXG | S_IRWXO;
        return permissionsMask & UInt16(attributes >> 16)
    }
    
    private static func itemIsSymbolicLink(_ attributes: UInt32) -> Bool {
        return itemFileType(attributes) == .LNK
    }
    
    // MARK: - init
    
    public init(archive: ZipArchive, stat: zip_stat) {
        self.archive = archive
        self.stat = stat
        self.vaild = stat.valid
        
        self.compressedSize = stat.comp_size
        self.uncompressedSize = stat.size
        self.index = stat.index
        self.CRC = UInt(stat.crc)
        
        self.modificationDate = Date(timeIntervalSince1970: TimeInterval(stat.mtime))
        self.compressionMethod = CompressionMethod(rawValue: Int32(stat.comp_method))
        self.encryptionMethod = EncryptionMethod(rawValue: stat.encryption_method)
        self.compressionLevel = ZipEntry.getCompressionlevel(stat: stat)
        
        var opsys: UInt8 = 0
        var attributes: UInt32 = 0
        if zip_file_get_external_attributes(archive.archivePointer, stat.index, Condition.original.rawValue, &opsys, &attributes) == ZIP_ER_OK {
            self.externalAttributes = ExternalAttributes(operatingSystem: ZipOSPlatform(rawValue: opsys), attributes: attributes)
        } else {
            self.externalAttributes = ExternalAttributes(operatingSystem: .Dos, attributes: 0)
        }
        
        var posix:UInt16 = 420
        var isSysLink = false
        var name = String(cString: stat.name!, encoding: .utf8)
        let zipOS = self.externalAttributes.operatingSystem
        if zipOS == .Dos || zipOS == .WINDOWS_NTFS {
            // 自动转换档案名编码
            if let zipFN = zip_get_name(archive.archivePointer, index, ZipEncoding.raw.rawValue) {
                
                let nameLen = zipFN.withMemoryRebound(to: Int8.self, capacity: 8, {
                    return strlen($0)
                })
                let buff = UnsafeBufferPointer(start: zipFN, count: nameLen)
                let sourceData = Data(buffer: buff)
                var convertedString: NSString?
                _ = NSString.stringEncoding(for: sourceData, encodingOptions: nil, convertedString: &convertedString, usedLossyConversion: nil)
                if let cs = convertedString {
                    name =  cs as String
                }
            }
        }
        if zipOS == .UNIX || zipOS == .OSX || zipOS == .MACINTOSH {
            posix = UInt16(ZipEntry.itemPermissions(self.externalAttributes.attributes))
            isSysLink = ZipEntry.itemIsSymbolicLink(self.externalAttributes.attributes)
        }
        self.isDirectory = attributes > 0 ? ZipEntry.itemIsDirectory(self.externalAttributes) : (name!.last == "/")
        self.isSymbolicLink = isSysLink
        self.posixPermission = posix
        self.fileName = name!
    }
    
    // MARK: - attributes
    
    public func setExternalAttributes(operatingSystem: ZipOSPlatform, attributes: UInt32) throws {
        try checkZipResult(zip_file_set_external_attributes(archive.archivePointer, index, 0, operatingSystem.rawValue, attributes))
    }
    
    // MARK: - compression
    
    public func setCompression(method: CompressionMethod = .deflate, flags: CompressionLevel = .default) throws {
        try checkZipResult(zip_set_file_compression(archive.archivePointer, index, method.rawValue, flags.rawValue))
    }
    
    // MARK: - encryption
    
    public func setEncryption(method: EncryptionMethod) -> Bool {
        return checkIsSuccess(zip_file_set_encryption(archive.archivePointer, index, method.rawValue, nil))
    }
    
    public func setEncryption(method: EncryptionMethod, password: String) throws {
        try password.withCString { password in
            _ = try checkZipResult(zip_file_set_encryption(archive.archivePointer, index, method.rawValue, password))
        }
    }
    
    // MARK: - modify/remove Entries
    
    /// rename
    /// - Parameter name: the new name
    public func rename(name: String) -> Bool {
        return name.withCString { name in
            return checkIsSuccess(zip_file_rename(archive.archivePointer, index, name, ZIP_FL_ENC_UTF_8))
        }
    }
    
    /// 设定修改日期
    /// - Parameter date: date
    public func setModified(date: Date) throws {
        let time = time_t(date.timeIntervalSinceNow)
        try checkZipResult(zip_file_set_mtime(archive.archivePointer, index, time, 0))
    }
    
    /// Replace the entry
    /// - Parameter source: the zip source
    func replace(source: ZipSource) throws {
        try checkZipResult(zip_file_replace(archive.archivePointer, index, source.sourcePointer, ZIP_FL_ENC_UTF_8))
        
        // compensate unbalanced `free` inside `zip_file_replace`
        source.keep()
    }
    
    // MARK: - discard change

    /// undo changes to file in zip archive
    public func discardChange() -> Bool {
        return checkIsSuccess(zip_unchange(archive.archivePointer, index))
    }
    
    // MARK: - uncompress & compress
    
    private func openEntry(password: String = "", mode: OpenMode = .none) throws -> OpaquePointer {
        var zipFileHandler: OpaquePointer
        if password.isEmpty {
            zipFileHandler = try checkZipResult(zip_fopen_index(archive.archivePointer, index, zip_flags_t(mode.rawValue)))
        } else {
            zipFileHandler = try checkZipResult(zip_fopen_index_encrypted(archive.archivePointer, index, zip_flags_t(mode.rawValue), password))
        }
        return zipFileHandler
    }
    
    /// 提取 Entry 到 Data
    /// - Parameters:
    ///   - data: ref out data
    ///   - password: if has password, set it
    public func extract(to data: inout Data, password: String = "") throws -> Bool {
        let zipFileHandler = try openEntry(password: password, mode: .none)
        defer {
            _ = checkIsSuccess(zip_fclose(zipFileHandler))
        }
        
        var readNum: Int64 = 0
        var readSize: Int64 = 0
        let count: Int = 1024*100
        var buffer = [UInt8](repeating: 0, count: count)
        while true {
            readNum = try zipCast(checkZipResult(zip_fread(zipFileHandler, &buffer, zipCast(count))))
            if readNum <= 0 {
                break
            }
            readSize += readNum
            data.append(buffer, count: Int(readNum))
        }
        if readNum < 0 {
            return false
        }
        return true
    }
    
    /// Unzip the document
    /// - Parameters:
    ///   - path: *unzip to path*
    ///   - password: password
    ///   - overwrite: overwrite
    ///   - closure: progress report
    public func extract(to path: String, password: String = "", overwrite: Bool = true, _ closure: ((String, Double) -> Bool)?) throws -> Bool {
        if let pg = closure {
            if !pg(fileName, 0) {
                return false
            }
        }
        
        if FileManager.default.fileExists(atPath: path) {
            if !overwrite {
                return false
            }
        }
        if isDirectory {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            if let pg = closure {
                if !pg(fileName, 1.0) {
                    return false
                }
            }
            return true
        } else {
            var readNum: Int64 = 0
            var readSize: Int64 = 0
            let count: Int = 1024*100
            let saveUrl = URL(fileURLWithPath: path)
            var buffer = [UInt8](repeating: 0, count: count)
            let zipHandler = try openEntry(password: password, mode: .none)
            defer {
                _ = checkIsSuccess(zip_fclose(zipHandler))
            }
            if !FileManager.default.fileExists(atPath: saveUrl.deletingLastPathComponent().path) {
                try FileManager.default.createDirectory(at: saveUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            }
            FileManager.default.createFile(atPath: path, contents: nil)
            
            guard let fileHandler = FileHandle(forWritingAtPath: path) else {
                return false
            }
            defer {
                fileHandler.closeFile()
            }
            fileHandler.seek(toFileOffset: 0)
            while true {
                readNum = try zipCast(checkZipResult(zip_fread(zipHandler, &buffer, zipCast(count))))
                if readNum <= 0 {
                    break
                }
                readSize += readNum
                autoreleasepool {
                    let data = Data(bytes: buffer, count: Int(readNum))
                    fileHandler.write(data)
                }
                if let pg = closure {
                    
                    let pn = Double(readSize) / Double(uncompressedSize)
                    if !pg(fileName, pn) {
                        return false
                    }
                }
            }
            if readNum < 0 {
                return false
            }
            
            let att: [FileAttributeKey : Any] = [
                FileAttributeKey.posixPermissions: posixPermission,
                FileAttributeKey.modificationDate: modificationDate
                ]
            try FileManager.default.setAttributes(att, ofItemAtPath: path)
            return true
        }
    }
    
    public func delete() -> Bool {
        return archive.deleteEntry(index: index)
    }
    
}
