//
//  FileManager.swift
//  devices
//
//  Created by Эля Корельская on 08.02.2024.
//

import UIKit

extension FileManager {

    // MARK: - Public

    // получаем путь до папки документы
    public var documentsDirectory: URL? {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else {
            print("Ошибка: Не удалось получить директорию документов")
            return nil
        }
        return documentsDirectory
    }

    // получаем путь до искомого файла
    public func fileURL(for fileName: String, in directory: URL) -> URL {
        return directory.appendingPathComponent(fileName)
    }

    // возвращаем дату создания файла
    public func fileCreationDate(fileURL: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let creationDate = attributes[.creationDate] as? Date {
                return creationDate
            }
        } catch {
            print("fileCreationDate: Ошибка при получении атрибутов: \(error.localizedDescription)")
        }
        return nil
    }

    // перемещаем файл в директорию
    public func moveFile(file: URL, to directory: URL, completion: @escaping (Bool, Error?) -> Void) {
        let fileManager = FileManager.default

        do {
            if fileManager.fileExists(atPath: directory.path) {
                try fileManager.removeItem(at: directory)
                print("Старый файл в документах удален: \(directory)")
            }
            try fileManager.moveItem(at: file, to: directory)
            completion(true, nil)
        } catch {
            print("Ошибка при перемещении файла: \(error.localizedDescription)")
            completion(false, error)
        }
    }

    // перемещаем файл в директорию
    public func removeFile(file: URL) {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: file.path) {
                try fileManager.removeItem(at: file)
            }
        } catch {
        }
    }
}
