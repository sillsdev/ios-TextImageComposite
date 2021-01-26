//
//  FileUtil.swift
//  TICExampleApp
//
//  Created by hubbard on 1/25/21.
//

import Foundation

public func getCreateSupportDirectory(_ directory: String, excludeFromBackup: Bool = false) -> URL? {
    var applicationSupportDirectory: URL?
    do {
        let bundleId = Bundle.main.bundleIdentifier
        let pathComponent = directory.isEmpty ? bundleId : bundleId! + "/" + directory
        let fileURL = try FileManager.default.findOrCreateDirectory(.applicationSupportDirectory, in: .userDomainMask, appendPathComponent: pathComponent)
        applicationSupportDirectory = URL(fileURLWithPath: fileURL, isDirectory: true)
        if ((applicationSupportDirectory != nil) && excludeFromBackup) {
            let excluded = addSkipBackupAttributeToItemAtURL(url: applicationSupportDirectory!)
            if !excluded {
                NSLog("Failed to exclude folder from backup")
            }
        }
    } catch let error as NSError {
        NSLog("Error on application Support Directory" + error.description)
    }
    return applicationSupportDirectory
}
public func addSkipBackupAttributeToItemAtURL(url: URL) -> Bool
{
    var success: Bool
    var urlCopy = url
    do {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try urlCopy.setResourceValues(resourceValues)
        success = true
    } catch let error as NSError {
        success = false
        print("Error excluding \(url.lastPathComponent) from backup \(error)");
    }
    return success
}
