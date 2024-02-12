//
//  NetworkManager.swift
//  devices
//
//  Created by Эля Корельская on 27.01.2024.
//

import UIKit

final class NetworkManager {

    // MARK: - Function

    public func downloadFile(url: URL, fileURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { file, _, error in
            if let file = file, error == nil {
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                        print("Старый файл в документах удален: \(fileURL)")
                    }
                    FileManager.default.moveFile(file: file, to: fileURL) { success, error in
                        if success {
                            print("Новый файл добавлен в документы: \(fileURL)")
                            completion(.success(()))
                        } else {
                            print(
                                "Ошибка обработки файла в документах:" +
                                "\(error?.localizedDescription ?? "Unknown error")"
                            )
                            completion(.failure(error ?? NSError(domain: "UnknownErrorDomain", code: 0, userInfo: nil)))
                        }
                    }
                } catch {
                    print("Ошибка обработки файла в документах: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            } else {
                let downloadError = NSError(
                    domain: "DownloadErrorDomain",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: error?.localizedDescription ?? "Неизвестная ошибка"]
                )
                print("Ошибка скачивания файла в документы: \(downloadError.localizedDescription)")
                completion(.failure(downloadError))
            }
        }
        task.resume()
    }
}
