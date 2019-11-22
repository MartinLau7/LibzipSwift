import libzip
import Foundation

// MARK: - struct

public struct OpenMode: RawRepresentable {
    public let rawValue: Int32
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let none = OpenMode(rawValue: Int32.zero)
    public static let checkConsistency = OpenMode(rawValue: ZIP_CHECKCONS)
    public static let create = OpenMode(rawValue: ZIP_CREATE)
    public static let exclusive = OpenMode(rawValue: ZIP_EXCL)
    public static let truncate = OpenMode(rawValue: ZIP_TRUNCATE)
    public static let readOnly = OpenMode(rawValue: ZIP_RDONLY)
}

public struct CompressionMethod: RawRepresentable {
    public let rawValue: Int32
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let `default` = CompressionMethod(rawValue: ZIP_CM_DEFAULT)
    public static let store = CompressionMethod(rawValue: ZIP_CM_STORE)
    public static let deflate = CompressionMethod(rawValue: ZIP_CM_DEFLATE)
    public static let deflate64 = CompressionMethod(rawValue: ZIP_CM_DEFLATE64)
}

public struct EncryptionMethod: RawRepresentable {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let none          = EncryptionMethod(rawValue: UInt16(ZIP_EM_NONE))
    public static let tradpkware    = EncryptionMethod(rawValue: UInt16(ZIP_EM_TRAD_PKWARE))
    public static let aes128        = EncryptionMethod(rawValue: UInt16(ZIP_EM_AES_128))
    public static let aes192        = EncryptionMethod(rawValue: UInt16(ZIP_EM_AES_192))
    public static let aes256        = EncryptionMethod(rawValue: UInt16(ZIP_EM_AES_256))
}

public struct CompressionLevel: RawRepresentable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let `default` = CompressionLevel(rawValue: 0)
    public static let fastest = CompressionLevel(rawValue: 1)
    public static let best = CompressionLevel(rawValue: 9)
}

public struct ExternalAttributes {
    public let operatingSystem: ZipOSPlatform
    public var attributes: UInt32
}

/// entry condition
public struct Condition: RawRepresentable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let original = Condition(rawValue: ZIP_FL_UNCHANGED)
    public static let last = Condition(rawValue: 0)
}

/// zip Encoding
public struct ZipEncoding: RawRepresentable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let guess = ZipEncoding(rawValue: ZIP_FL_ENC_GUESS)
    public static let strict = ZipEncoding(rawValue: ZIP_FL_ENC_STRICT)
    public static let raw = ZipEncoding(rawValue: ZIP_FL_ENC_RAW)
    public static let utf8 = ZipEncoding(rawValue: ZIP_FL_ENC_UTF_8)
}

/// zip OS Platform
public struct ZipOSPlatform: OptionSet {
    public let rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public static let Dos               = ZipOSPlatform(rawValue: 0x00)
    public static let UNIX              = ZipOSPlatform(rawValue: 0x03)
    public static let OS2              = ZipOSPlatform(rawValue: 0x06)
    public static let MACINTOSH         = ZipOSPlatform(rawValue: 0x07)
    public static let WINDOWS_NTFS      = ZipOSPlatform(rawValue: 0x0a)
    public static let OSX              = ZipOSPlatform(rawValue: 0x013)
}

// MARK: - internal Struct

enum ZipSourceCommand {
    case Open
    case Read
    case Close
    case Stat
    case Error
    case Free
    case Seek
    case Tell
    case BeginWrite
    case CommitWrite
    case RollbackWrite
    case Write
    case SeekWrite
    case TellWrite
    case Supports
    case Remove
    case GetCompressionFlags
    case BeginWriteCloning
}

// MARK: - Optional Unwrapping

extension Optional {
    internal func unwrapped() throws -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            assertionFailure()
            throw ZipError.internalInconsistency
        }
    }
    
    internal func unwrapped(or error: zip_error) throws -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            throw ZipError.zipError(error)
        }
    }
}

// MARK: - Int Cast

internal func zipCast<T, U>(_ value: T) throws -> U where T: BinaryInteger, U: BinaryInteger {
    if let result = U(exactly: value) {
        return result
    } else {
        throw ZipError.integerCastFailed
    }
}
