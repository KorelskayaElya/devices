//
//  FileStore.swift
//  devices
//
//  Created by Эля Корельская on 27.01.2024.
//

import UIKit

public final class FileStore {
    
    // MARK: - Properties
    /// время жизни файла в секундах
    public let secondsOfFilesLife = 30
    private let fileName = "Apple_mobile_device_types.txt"
    public var devicesInfo: [String: String] = [:]
    public static let shared: FileStore = .init()
    private init() {}
    
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
                        devicesInfo[key] = value
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
    // возвращает путь до бандла
    internal func findPathToFileInBundle() -> URL? {
        guard let bundlePath = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("Файл не найден в бандле")
            return nil
        }
        let fileURL = URL(fileURLWithPath: bundlePath)
        return fileURL
    }
    
    // возвращает путь до папки документ
    internal func findPathToFileInDocument() -> URL? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            return fileURL
        }
        return nil
    }
    
    // парсим файл в директории Document
    internal func parsingFileInDocument(fileURL: URL) {
        parsingFile(fileURL: fileURL, encoding: .utf8)
    }
    
    // парсим файл в бандле
    internal func parsingFileInBundle(fileURL: URL) {
        parsingFile(fileURL: fileURL, encoding: .isoLatin1)
    }
    
    // MARK: - Public
    // по ключу отдаем значение девайса
    public func getDeviceDescription(key: String) -> String? {
        return devicesInfo[key]
    }
    
    // получаем данные о модели
    public func getModelName() -> String {
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
    
    // проверяем время жизни файла(ов)
    public func checkCreateDate(seconds: TimeInterval, fileURL: URL) -> Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let creationDate = attributes[.creationDate] as? Date {
                let currentTime = Date()
                let timeDifference = currentTime.timeIntervalSince(creationDate)
                if timeDifference > seconds {
                    print("checkCreateDate: Файл старый - Время в секундах с момента создания файла \(timeDifference)")
                    return true
                } else {
                    print("checkCreateDate: Файл новый")
                    return false
                }
            }
        } catch {
            print("checkCreateDate: Ошибка при получении атрибутов: \(error.localizedDescription)")
            return true
        }
        return true
    }
}
