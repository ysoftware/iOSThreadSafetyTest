//
//  ViewController.swift
//  ThreadTest
//
//  Created by Ерохин Ярослав Игоревич on 10.01.2021.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    var controllers: [ColorController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupColors()
    }

    private func setupViews() {
        view.addSubview(button)

        button.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupColors() {
        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 1

        view.addSubview(verticalStack)
        verticalStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
        }

        for _ in 0...19 {
            let horizontalStack = UIStackView()
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .fillEqually
            horizontalStack.spacing = 1
            verticalStack.addArrangedSubview(horizontalStack)

            for _ in 0...10 {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .black
                horizontalStack.addArrangedSubview(view)

                view.snp.makeConstraints {
                    $0.height.equalTo(view.snp.width)
                }

                let controller = ColorController()
                controller.view = view
                controllers.append(controller)
            }
        }
    }

    private func start(_ action: UIAction) {
        FashionService.color = nil

        controllers.forEach { controller in
            controller.view?.backgroundColor = .gray
            controller.refresh()
        }
    }

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("GO ON PIGS", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: start), for: .primaryActionTriggered)
        return button
    }()
}

class ColorController {
    weak var view: UIView?

    func refresh() {
        FashionService.fetchNewFashion { newColor in
            self.view?.backgroundColor = newColor
        }
    }
}

enum FashionService {

    static let lock = NSLock()
    static var color: UIColor?

    static func fetchNewFashion(completion: @escaping (UIColor) -> Void) {
        DispatchQueue.global().async {
            lock.lock()

            if let color = color {
                DispatchQueue.main.async {
                    completion(color)
                }
                lock.unlock()
            } else {
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(200)) {
                    let newColor = [UIColor.red, .blue, .green, .cyan, .magenta].randomElement()!
                    color = newColor

                    DispatchQueue.main.async {
                        completion(newColor)
                    }
                    lock.unlock()
                }
            }
        }
    }
}
