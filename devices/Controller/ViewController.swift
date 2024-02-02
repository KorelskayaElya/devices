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
        if isBadDocumentFile {
            print("Файл в документах старый - нужно скачать новый")
            NetworkManager().downloadFile { result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success:
                        print("Файл в документах скачан успешно")
                        self?.tableData = DeviceManager().showDevicesInfo(isDevicesFileToParse: false)
                    case .failure(let error):
                        print("Ошибка при скачивании файла: \(error.localizedDescription)")
                        print("Используем файл из devicesFile")
                        self?.tableData = DeviceManager().showDevicesInfo(isDevicesFileToParse: true)
                    }
                    self?.deviceModel = DeviceManager().showUsingDevice()
                }
            }
        } else {
            print("Файл в документах новый - скачивать не нужно")
            tableData = DeviceManager().showDevicesInfo(isDevicesFileToParse: false)
            deviceModel = DeviceManager().showUsingDevice()
        }
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
