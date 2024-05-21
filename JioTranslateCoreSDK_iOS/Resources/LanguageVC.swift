//
//  LanguageVC.swift
//  JioTranslateCoreSDKDemo
//
//  Created by Ramakrishna1 M on 20/05/24.
//

import UIKit
import JioTranslateCoreSDKiOS

class LanguageVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var languages: [SupportedLanguage] = JioTranslateManager.shared.getSupportedLanguages()

    var didSelectLanguage: ((SupportedLanguage) -> Void)?
    var selectedLanguageIndex: Int?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Language Preference"
        setupTableView()
        
        // Add a gesture recognizer to dismiss the bottom sheet when tapped outside
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
//        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(LanguageCell.self, forCellReuseIdentifier: "LanguageCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissBottomSheet() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
        let language = languages[indexPath.row]
        cell.configure(with: language, isSelected: indexPath.row == selectedLanguageIndex)
        return cell
    }
    
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLanguageIndex = indexPath.row
        tableView.reloadData()
        
        let selectedLanguage = languages[indexPath.row]
        didSelectLanguage?(selectedLanguage)
        dismissBottomSheet()
    }
}

class LanguageCell: UITableViewCell {
    
    let languageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(languageLabel)
        
        NSLayoutConstraint.activate([
            languageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            languageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            languageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with language: SupportedLanguage, isSelected: Bool) {
        languageLabel.text = language.languageName
        if isSelected {
            backgroundColor = .lightGray // Set your desired color for selected cell
        } else {
            backgroundColor = .white // Reset background color for unselected cells
        }
    }
}
