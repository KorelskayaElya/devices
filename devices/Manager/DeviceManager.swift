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
    private var isTodayString = ""
    private let url = URL(string: "https://gist.githubusercontent.com/adamawolf/3048717/raw/07ad6645b25205ef2072a560e660c636c8330626/Apple_mobile_device_types.txt")!

    // MARK: - Init

    convenience init(fileExistenceCheck: Bool = true) {
        self.init()
        if fileExistenceCheck, let documentFileURL = FileManager().documentsDirectory {
            let fileURL = FileManager.default.fileURL(for: DeviceManager.fileName, in: documentFileURL)
            if existingFile(fileURL: fileURL) {
                let deviceData = parsingFileInDocument(fileURL: fileURL)
                devicesInfo = deviceData
                // проверка на актуальность файла
                let fileCreationDate = FileManager.default.fileCreationDate(
                    fileURL: fileURL) ?? Date(timeIntervalSinceReferenceDate: 0)
                isTodayString = Calendar.current.isDateInToday(fileCreationDate) ? "is Today" : "is not Today"
                if isTodayString == "is not Today" {
                    downloadNewFile(url: url, fileURL: fileURL) { [weak self] newDeviceData in
                        guard let newDeviceData = newDeviceData else { return }
                        self?.devicesInfo = newDeviceData
                    }
                }
            } else {
                print("Файл '\(DeviceManager.fileName)' не найден в директории документов")
                let deviceData = parseDeviceFile(content: devicesFile)
                devicesInfo = deviceData
                downloadNewFile(url: url, fileURL: fileURL) { [weak self] newDeviceData in
                    guard let newDeviceData = newDeviceData else { return }
                    self?.devicesInfo = newDeviceData
                }
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

    internal func downloadNewFile(url: URL, fileURL: URL, completion: @escaping ([String: String]?) -> Void) {
        NetworkManager().downloadFile(url: url, fileURL: fileURL) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Файл в документах скачан успешно")
                    let deviceData = self.parsingFileInDocument(fileURL: fileURL)
                    self.devicesInfo = deviceData
                    completion(deviceData)
                case .failure(let error):
                    print("Ошибка при скачивании файла: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }

    // по ключу отдаем значение девайса
    internal func getDeviceDescription(key: String) -> String? {
        return devicesInfo[key]
    }

    // показываем информацию о конкретном девайсе
    internal func showUsingDevice() -> String {
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
