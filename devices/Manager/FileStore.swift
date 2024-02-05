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

    // MARK: - Internal

    // возвращает путь до папки документ
    internal func findPathToFileInDocument() -> URL? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            return fileURL
        }
        return nil
    }

    // проверяем время жизни файла(ов)
    internal func checkCreateDate(seconds: TimeInterval, fileURL: URL) -> Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let creationDate = attributes[.creationDate] as? Date {
                let currentTime = Date()
                let timeDifference = currentTime.timeIntervalSince(creationDate)
                print("checkCreateDate: Время в секундах с момента создания файла \(timeDifference)")
                return timeDifference > seconds
            }
        } catch {
            print("checkCreateDate: Ошибка при получении атрибутов: \(error.localizedDescription)")
        }
        return true
    }
}
