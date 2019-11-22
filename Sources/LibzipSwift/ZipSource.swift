//
//  File.swift
//  
//
//  Created by MartinLau on 2019/11/30.
//

import libzip
import Foundation

class ZipSource: ZipErrorHandler {
        
    var sourcePointer: OpaquePointer!
    
    // MARK: - error content
    
    internal var error: ZipError? {
        return .zipError(zip_source_error(sourcePointer).pointee)
    }
    
    // MARK: - init
    
    deinit {
        zip_source_free(sourcePointer)
    }
    
    init(buffer: UnsafeRawPointer, length: Int, freeWhenDone: Bool) throws {
       var error = zip_error_t()
        self.sourcePointer = try zip_source_buffer_create(buffer, zipCast(length), freeWhenDone ? 0 : 1, &error).unwrapped(or: error)
    }
    
    init(fileName: String, start: Int = 0, length: Int = -1) throws {
        self.sourcePointer =  try fileName.withCString({ fileName in
            var error =  zip_error_t()
            return try zip_source_file_create(fileName, zipCast(start), zipCast(length), &error).unwrapped(or: error)
        })
    }
    
    init(url: URL, start: Int = 0, length: Int = -1) throws {
        self.sourcePointer = try url.withUnsafeFileSystemRepresentation { filename in
            if let filename = filename {
                var error = zip_error_t()
                return try zip_source_file_create(filename, zipCast(start), zipCast(length), &error).unwrapped(or: error)
            } else {
                throw ZipError.unsupportedURL
            }
        }
    }
    
    init(file: UnsafeMutablePointer<FILE>, start: Int = 0, length: Int = -1) throws {
        var error = zip_error_t()
        self.sourcePointer = try zip_source_filep_create(file, zipCast(start), zipCast(length), &error).unwrapped(or: error)
    }
    
    init(callback: @escaping zip_source_callback, userdata: UnsafeMutableRawPointer? = nil) throws {
        var error = zip_error_t()
        self.sourcePointer = try zip_source_function_create(callback, userdata, &error).unwrapped(or: error)
    }
    
    // MARK: - other
    
    ///  increment reference count of zip data source
    func keep() {
        zip_source_keep(sourcePointer)
    }
    
}

