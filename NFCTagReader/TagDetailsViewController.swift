//
//  TagDetailsViewController 2.swift
//  NFCTagReader
//
//  Created by alwishihab on 24/05/25.
//  Copyright © 2025 Apple. All rights reserved.
//


import UIKit

class TagDetailsViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Tag information
    private let aidLabel = UILabel()
    private let dataLabel = UILabel()
    private let historyLabel = UILabel()
    private let pcLabel = UILabel()
    private let idLabel = UILabel()
    private let snLabel = UILabel()
    
    // Tag data
    var tagAID: String?
    var tagData: Data?
    var tagHistory: String?
    var tagPC: Bool?
    var tagID: Data?
    var tagSN: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLabels()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .systemGray
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Tag Details"
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // Add labels to stack view
        [aidLabel, dataLabel, historyLabel, pcLabel, idLabel, snLabel].forEach { label in
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            stackView.addArrangedSubview(label)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateLabels() {
        aidLabel.text = "TAG AID: \(tagAID ?? "N/A")"
        dataLabel.text = "Tag Data: \(tagData?.description ?? "N/A")"
        historyLabel.text = "TAG History: \(tagHistory?.description ?? "N/A")"
        pcLabel.text = "TAG PC: \(tagPC?.description ?? "N/A")"
        idLabel.text = "TAG ID: \(tagID?.description ?? "N/A")"
        snLabel.text = "TAG SN: \(tagSN ?? "N/A")"
    }
} 
