//
//  DeviceManager.swift
//  devices
//
//  Created by Эля Корельская on 02.02.2024.
//

import UIKit

final class DeviceManager {

    // MARK: - Properties

    static let fileName = "Apple_mobile_device_types.txt"
    public var devicesInfo: [String: String] = [:]

    // MARK: - Init

    convenience init(fileExistenceCheck: Bool = true) {
        self.init()
        if fileExistenceCheck, let documentFileURL = FileManager().documentsDirectory {
            let fileURL = FileManager.default.fileURL(for: DeviceManager.fileName, in: documentFileURL)
            if existingFile(fileURL: fileURL) {
                let deviceData = parsingFileInDocument(fileURL: fileURL)
                devicesInfo = deviceData
            } else {
                print("Файл '\(DeviceManager.fileName)' не найден в директории документов")
                let deviceData = parseDeviceFile(content: devicesFile)
                devicesInfo = deviceData
            }
        }
    }

    // MARK: - Private

    // парсинг
    private func parseDeviceFile(content: String) -> [String: String] {
        let lines = content.components(separatedBy: "\n")
        for line in lines {
            let components = line.components(separatedBy: ":")
            if components.count == 2 {
                let key = components[0].trimmingCharacters(in: .whitespaces)
                let value = components[1].trimmingCharacters(in: .whitespaces)
                devicesInfo[key] = value
            }
        }
        return devicesInfo
    }

    // MARK: - Internal

    // проверяем есть ли файл
    internal func existingFile(fileURL: URL) -> Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    // парсим файл в директории Document
    internal func parsingFileInDocument(fileURL: URL) -> [String: String] {
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let devicesData = parseDeviceFile(content: fileContent)
            return devicesData
        } catch let error {
            print("Ошибка при чтении файла: \(error.localizedDescription)")
        }
        return [:]
    }

    // по ключу отдаем значение девайса
    internal func getDeviceDescription(key: String) -> String? {
        return devicesInfo[key]
    }

    // показываем информацию о конкретном девайсе
    internal func showUsingDevice() -> String {
        print(getDeviceDescription(key: getModelName()) ?? "not device")
        return getDeviceDescription(key: getModelName()) ?? "not device"
    }
}
extension DeviceManager {

    // MARK: - Internal
    // получаем данные о модели
    internal func getModelName() -> String {
        var machineString = String()
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        machineString = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return machineString
    }
}
