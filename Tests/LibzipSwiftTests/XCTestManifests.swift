import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LibzipSwiftTests.allTests),
        testCase(ZipArchiveTests.allTest)
    ]
}
#endif
