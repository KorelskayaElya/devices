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
    private var isBadDocumentFile: Bool {
        if let documentFileURL = FileStore.shared.findPathToFileInDocument() {
            return FileStore.shared.checkCreateDate(
                seconds: TimeInterval(FileStore.shared.secondsOfFilesLife),
                fileURL: documentFileURL)
        }
        return true
    }
    private let url = URL(string: "https://gist.githubusercontent.com/adamawolf/3048717/raw/07ad6645b25205ef2072a560e660c636c8330626/Apple_mobile_device_types.txt")!
    private lazy var deviceManager: DeviceManager = {
        return DeviceManager()
    }()
    private lazy var networkManager: NetworkManager = {
        return NetworkManager()
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
        let deviceManager = DeviceManager()
        let networkManager = NetworkManager()
        if deviceManager.existingFileInDocuments() {
            tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: false)
            guard let fileURL = FileStore.shared.findPathToFileInDocument() else {
                print("URL не найден")
                return
            }
            tableView.reloadData()
            if isBadDocumentFile {
                networkManager.downloadFile(url: url, fileURL: fileURL) { [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.async { [weak self] in
                        switch result {
                        case .success:
                            print("Файл в документах скачан успешно")
                            self?.tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: false)
                        case .failure(let error):
                            print("Ошибка при скачивании файла: \(error.localizedDescription)")
                            print("Используем девайсы из deviceInfo")
                        }
                        self?.tableView.reloadData()
                        self?.deviceModel = deviceManager.showUsingDevice()
                    }
                }
            } else {
                tableView.reloadData()
                deviceModel = deviceManager.showUsingDevice()
            }
        } else {
            tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: true)
            guard let fileURL = FileStore.shared.findPathToFileInDocument() else {
                print("URL не найден")
                return
            }
            networkManager.downloadFile(url: url, fileURL: fileURL) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success:
                        print("Файл в документах скачан успешно")
                        self?.tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: false)
                    case .failure(let error):
                        print("Ошибка при скачивании файла: \(error.localizedDescription)")
                        print("Используем девайсы из devicesFile")
                        self?.tableData = deviceManager.showDevicesInfo(isDevicesFileToParse: true)
                    }
                    self?.tableView.reloadData()
                    self?.deviceModel = deviceManager.showUsingDevice()
                }
            }
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
