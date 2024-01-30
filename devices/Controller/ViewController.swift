//
//  ViewController.swift
//  devices
//
//  Created by Эля Корельская on 26.01.2024.
//

import UIKit

final class ViewController: UIViewController {
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    // MARK: - Data
    private var tableData: [DeviceData] = []
    private var isBadBundleFile: Bool {
        if let bundleFileURL = FileStore.shared.findPathToFileInBundle() {
            return FileStore.shared.checkCreateDate(seconds: TimeInterval(FileStore.shared.secondsOfFilesLife),
                                                    fileURL: bundleFileURL)
        }
        return true
    }
    private var isBadDocumentFile: Bool {
        if let documentFileURL = FileStore.shared.findPathToFileInDocument() {
            return FileStore.shared.checkCreateDate(seconds: TimeInterval(FileStore.shared.secondsOfFilesLife),
                                                    fileURL: documentFileURL)
        }
        return true
    }
    private var deviceModel = ""
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()
        updateData()
    }
    // MARK: - Private
    private func constraints() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // парсим один из файлов
    private func showData(isBundleToParse: Bool) {
        // если время жизни документа в бандле не было просрочено - парсим файл в бандле
        if isBundleToParse {
            if let bundleFileURL = FileStore.shared.findPathToFileInBundle() {
                FileStore.shared.parsingFileInBundle(fileURL: bundleFileURL)
            }
        } else {
            if let documentFileURL = FileStore.shared.findPathToFileInDocument() {
                // иначе парсим документ
                FileStore.shared.parsingFileInDocument(fileURL: documentFileURL)
            }
        }
        // в любом случае показываем информацию о девайсах
        tableData = FileStore.shared.devicesInfo.map { DeviceData(key: $0.key, value: $0.value)}
        tableData = tableData.sorted { $0.key > $1.key }
    }
    // отображаем данные о девайсах
    private func updateData() {
        /// если время жизни документа в бандле было просрочено или иные причины
        /// невозможности воспользоваться файлом из бандла - проверяем существует
        /// ли файл в документах/время его жизни - или скачиваем новый
        if isBadBundleFile {
            print("Файл в бандле не используется")
            if isBadDocumentFile {
                print("Файл в документах старый - нужно скачать новый")
                NetworkManager().downloadFile { result in
                    DispatchQueue.main.async { [weak self] in
                        switch result {
                        case .success:
                            print("Файл в документах скачан успешно")
                            self?.showData(isBundleToParse: false)
                        case .failure(let error):
                            print("Ошибка при скачивании файла: \(error.localizedDescription)")
                            print("Используем файл из бандла")
                            self?.showData(isBundleToParse: true)
                        }
                        self?.tableView.reloadData()
                        // показываем информацию о конкретном девайсе
                        self?.deviceModel = FileStore.shared.getDeviceDescription(
                            key: FileStore.shared.getModelName()) ?? "not device"
                        print(self?.deviceModel ?? "not device")
                    }
                }
            } else {
                print("Файл в документах новый - скачивать не нужно")
                showData(isBundleToParse: false)
                tableView.reloadData()
                // показываем информацию о конкретном девайсе
                deviceModel = FileStore.shared.getDeviceDescription(key:
                FileStore.shared.getModelName()) ?? "not device"
                print(deviceModel)
            }
        } else {
            print("Используем файл в бандле")
            showData(isBundleToParse: true)
            tableView.reloadData()
            // показываем информацию о конкретном девайсе
            deviceModel = FileStore.shared.getDeviceDescription(key: FileStore.shared.getModelName()) ?? "not device"
            print(deviceModel)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = tableData[indexPath.row].value
        return cell
    }
}
