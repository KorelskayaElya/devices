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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()
        // TODO: Убрать потом принудительное удаление файла
        let documentDirectory = FileManager.default.documentsDirectory!
        let fileUrl = FileManager.default.fileURL(for: DeviceManager.fileName, in: documentDirectory)
        FileManager.default.removeFile(file: fileUrl)
        updateData()
        updateDataFromServer()
        getModelOfCurrentDevice()
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
        let devicesInfo = DeviceManager.sharedInstance.devicesInfo
        tableData = devicesInfo.map { DeviceData(key: $0.key, value: $0.value) }
                    .sorted { $0.key > $1.key }
        tableView.reloadData()
    }

    private func updateDataFromServer() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            DeviceManager.sharedInstance.loadModelsFromServerIfNeeded {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self?.updateData()
                }
            }
        }
    }

    private func getModelOfCurrentDevice() {
        print(DeviceManager.sharedInstance.showUsingDevice())
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
