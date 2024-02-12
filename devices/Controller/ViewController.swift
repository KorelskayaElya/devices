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
    private var deviceModel = ""
    private let url = URL(string: "https://gist.githubusercontent.com/adamawolf/3048717/raw/07ad6645b25205ef2072a560e660c636c8330626/Apple_mobile_device_types.txt")!
    private lazy var networkManager: NetworkManager = {
        return NetworkManager()
    }()
    private lazy var deviceManager: DeviceManager = {
        return DeviceManager()
    }()

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

    // отображаем данные о девайсах
    private func updateData() {
        let deviceManager = DeviceManager(fileExistenceCheck: true)
        tableData = deviceManager.devicesInfo.map { DeviceData(key: $0.key, value: $0.value) }
                    .sorted { $0.key > $1.key }
        tableView.reloadData()
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
//        let networkManager = NetworkManager()
//        let deviceManager = DeviceManager()
//        let fileManager = FileManager()
//        let documentDirectory = fileManager.documentsDirectory
//
//        guard let documentURL = documentDirectory else {
//            return
//        }
//
//        let fileURL = fileManager.fileURL(for: DeviceManager.fileName, in: documentURL)
//        // если файл существует в документах - отображаем девайсы из файла
//        if fileManager.fileExists(atPath: fileURL.path) {
//            tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: false)
//            tableView.reloadData()
//            // если файл просрочен - скачиваем новый
//            if isBadDocumentFile {
//                networkManager.downloadFile(url: url, fileURL: fileURL) { [weak self] result in
//                    guard let self = self else { return }
//                    DispatchQueue.main.async { [weak self] in
//                        switch result {
//                        case .success:
//                            print("Файл в документах скачан успешно")
//                            self?.tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: false)
//                        case .failure(let error):
//                            print("Ошибка при скачивании файла: \(error.localizedDescription)")
//                            print("Используем девайсы из deviceInfo")
//                        }
//                        self?.tableView.reloadData()
//                        self?.deviceModel = deviceManager.showUsingDevice()
//                    }
//                }
//                // файл не просрочен - просто отображаем модель телефона
//            } else {
//                tableView.reloadData()
//                deviceModel = deviceManager.showUsingDevice()
//            }
//            // файл не существует в документах - отображаем devicesFile
//        } else {
//            tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: true)
//            // скачиваем файл с сети
//            networkManager.downloadFile(url: url, fileURL: fileURL) { [weak self] result in
//                guard let self = self else { return }
//                DispatchQueue.main.async { [weak self] in
//                    switch result {
//                    case .success:
//                        print("Файл в документах скачан успешно")
//                        self?.tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: false)
//                    case .failure(let error):
//                        print("Ошибка при скачивании файла: \(error.localizedDescription)")
//                        print("Используем девайсы из devicesFile")
//                        self?.tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: true)
//                    }
//                    self?.tableView.reloadData()
//                    self?.deviceModel = deviceManager.showUsingDevice()
//                }
//            }
//        }
//    }
//    private var isBadDocumentFile: Bool {
//        // если нет доступа к файлу или файл просрочен - тогда true
//        guard let documentFileURL = FileManager.default.documentsDirectory else {
//            return true
//        }
//        let file = FileManager.default.fileURL(for: DeviceManager.fileName, in: documentFileURL)
//        // если дата создания еще сегодня, тогда файл не просрочен
//        let fileCreationDate = FileManager.default.fileCreationDate(
//            fileURL: file) ?? Date(timeIntervalSinceReferenceDate: 0)
//        if Calendar.current.isDateInToday(fileCreationDate) {
//            return false
//        } else {
//            return true
//        }
//    }
