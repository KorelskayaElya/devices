//
//  DeviceManager.swift
//  devices
//
//  Created by Эля Корельская on 02.02.2024.
//

import UIKit

final class DeviceManager {

    // MARK: - Properties

    private let fileName = "Apple_mobile_device_types.txt"

    // MARK: - Private

    private func parsingFile(fileURL: URL, encoding: String.Encoding) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let fileContent = try String(contentsOf: fileURL, encoding: encoding)
                let lines = fileContent.components(separatedBy: "\n")
                for line in lines {
                    let components = line.components(separatedBy: ":")
                    if components.count == 2 {
                        let key = components[0].trimmingCharacters(in: .whitespaces)
                        let value = components[1].trimmingCharacters(in: .whitespaces)
                        FileStore.shared.devicesInfo[key] = value
                    }
                }
            } catch {
                print("Ошибка при чтении файла: \(error.localizedDescription)")
            }
        } else {
            print("Файл '\(fileName)' не найден в директории Documents.")
        }
    }

    // MARK: - Internal

    // парсим файл в директории Document
    internal func parsingFileInDocument(fileURL: URL) {
        parsingFile(fileURL: fileURL, encoding: .utf8)
    }

    // парсим файл в бандле - не используется
    internal func parsingFileInBundle(fileURL: URL) {
        parsingFile(fileURL: fileURL, encoding: .isoLatin1)
    }

    // парсим файл девайсов
    internal func parsingFileInDeviceFile(file: String) {
        let lines = devicesFile.components(separatedBy: "\n")
        for line in lines {
            let components = line.components(separatedBy: ":")
            if components.count == 2 {
                let key = components[0].trimmingCharacters(in: .whitespaces)
                let value = components[1].trimmingCharacters(in: .whitespaces)
                FileStore.shared.devicesInfo[key] = value
            }
        }
    }

    // по ключу отдаем значение девайса
    internal func getDeviceDescription(key: String) -> String? {
        return FileStore.shared.devicesInfo[key]
    }

    // парсим один из файлов
    internal func showDevicesInfo(isDevicesFileToParse: Bool) -> [DeviceData] {
        // если была ошибка сети - парсим файл девайсов
        if isDevicesFileToParse {
            parsingFileInDeviceFile(file: devicesFile)
        } else {
            if let documentFileURL = FileStore.shared.findPathToFileInDocument() {
                // иначе парсим документ
                parsingFileInDocument(fileURL: documentFileURL)
            }
        }
        // в любом случае показываем информацию о девайсах
        return FileStore.shared.devicesInfo
            .map { DeviceData(key: $0.key, value: $0.value) }
            .sorted { $0.key > $1.key }
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
