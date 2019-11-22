import libzip
import Foundation

// MARK: - zip Error

public enum ZipError: Error {
    case zipError(zip_error_t)
    case integerCastFailed
    case unsupportedURL
    case fileNotExist
    case internalInconsistency
//    case
}

extension ZipError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case var .zipError(error):
            return String(cString: zip_error_strerror(&error))
        case .integerCastFailed:
            return "Failed to cast integer value."
        case .unsupportedURL:
            return "LibzipSwift supports file URLs only."
        case .fileNotExist:
            return "The zip file does not exist."
        case .internalInconsistency:
            return "LibzipSwift internal inconsistency."
        }
    }
}

// MARK: - Protocol

internal protocol ZipErrorHandler {
    var error: ZipError? { get }
}

extension ZipErrorHandler {
    
    // MARK: - Error Code Handling
    
    internal func checkZipError(_ errorCode: Int32) throws {
        switch errorCode {
        case ZIP_ER_OK:
            return
        case let errorCode:
            throw ZipError.zipError(.init(zip_err: errorCode, sys_err: 0, str: nil))
        }
    }
    
    internal func checkIsSuccess(_ errorCode: Int32) -> Bool {
        if errorCode == ZIP_ER_OK {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    internal func checkZipResult<T>(_ returnCode: T) throws -> T where T: BinaryInteger {
        if returnCode == -1 {
            throw try error.unwrapped()
        } else {
            return returnCode
        }
    }
    
    internal func checkZipResult<T>(_ value: T?) throws -> T {
        switch value {
        case let .some(value):
            return value
        case .none:
            throw try error.unwrapped()
        }
    }
    
}
