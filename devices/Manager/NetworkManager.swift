//
//  NetworkManager.swift
//  devices
//
//  Created by Эля Корельская on 27.01.2024.
//

import UIKit

final class NetworkManager {

    // MARK: - Properties

    private let fileURL: URL? = {
        let urlString = "https://gist.githubusercontent.com/" + "adamawolf/3048717/raw/"
        + "07ad6645b25205ef2072a560e660c636c8330626/Apple_mobile_device_types.txt"
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        return url
    }()

    // MARK: - Function

    public func downloadFile(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let fileURL = fileURL else {
            completion(.failure(DownloadError.invalidURL))
            return
        }

        let task = URLSession.shared.downloadTask(with: fileURL) { file, _, error in
            if let file = file, error == nil {
                guard let destinationURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first?
                    .appendingPathComponent(fileURL.lastPathComponent) else {
                        completion(.failure(DownloadError.invalidDestinationURL))
                        return
                }
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                        print("Старый файл в документах удален: \(destinationURL)")
                    }
                    try FileManager.default.moveItem(at: file, to: destinationURL)
                    print("Новый файл добавлен в документы: \(destinationURL)")
                    completion(.success(()))
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
