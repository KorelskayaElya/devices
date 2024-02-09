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

    // проверяем просрочен ли файл (24 часа)
    public func fileCreationDate(fileURL: URL) -> Date? {
        let secondsInDay: TimeInterval = 24 * 60 * 60

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let creationDate = attributes[.creationDate] as? Date {
                let currentTime = Date()
                let timeDifference = currentTime.timeIntervalSince(creationDate)
                print(timeDifference, "time_difference")
                if abs(timeDifference) <= secondsInDay {
                    return creationDate
                } else {
                    return nil
                }
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

    // тест методов
    public func testFileManager() {
        guard let documentsDirectory = FileManager.default.documentsDirectory else { return }
        print("document directory - \(FileManager.default.documentsDirectory!.path)")
        let fileInDocumentDirectoryURL = FileManager.default.fileURL(for: "test.txt", in: documentsDirectory)
        print("text.txt in document directory - \(fileInDocumentDirectoryURL)")
        let fileInTemporaryDirectoryURL = FileManager.default.fileURL(
            for: "test.txt", in: FileManager.default.temporaryDirectory)

        do {
            let fileData = "123456".data(using: .utf8)
            try fileData?.write(to: fileInTemporaryDirectoryURL)
        } catch {
            print("can't save test.txt in temporary directory - \(error.localizedDescription)")
        }
        guard let fileInTemporaryDirectoryCreationDate = FileManager.default.fileCreationDate(
            fileURL: fileInTemporaryDirectoryURL) else {
            return
        }
        print("creation date test.txt in temporary directory - \(fileInTemporaryDirectoryCreationDate)")
        FileManager.default.moveFile(
            file: fileInTemporaryDirectoryURL,
            to: documentsDirectory) { success, _  in
            if success {
                print("creation date test.txt in document directory - \(fileInTemporaryDirectoryCreationDate)")
            }
        }
    }
}
