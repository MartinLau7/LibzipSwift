import XCTest

import LibzipSwiftTests

var tests = [XCTestCaseEntry]()
tests += LibzipSwiftTests.allTests()
tests += ZipArchiveTests.allTests()
XCTMain(tests)
