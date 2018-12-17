//
//  FirstViewController.swift
//  EmailValidatorSwift
//
//  Created by Hyuk Hur on 2018-11-25.
//  Copyright © 2018 Hyuk Hur. All rights reserved.
//

import UIKit

protocol SatisfyingView {
    var satisfy: Bool { get set }
}

class FirstViewController: UITableViewController {
    let emailValidator = EmailValidator.regExAndKickbox
    @IBOutlet var accessaryView: UIToolbar!

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.row)", for: indexPath)
    }

    override var inputAccessoryView: UIView? {
        return  accessaryView
    }
}

extension UITextField: SatisfyingView {
    var satisfy: Bool {
        set {
            clearButtonMode = newValue ? .never : .always
        }
        get {
            return clearButtonMode == .never
        }
    }

    func replacedText(range: NSRange, replacementString string: String) -> String {
        guard let text = text, let textRange = Range(range, in: text) else {
            return string
        }
        return text.replacingCharacters(in: textRange, with: string)
    }

    @objc func suggestedDomainDidTap(item: UIBarButtonItem) {
        guard let title = item.title, let text = text else {
            return
        }
        guard text.hasSuffix(title) == false else {
            return
        }
        self.text = "\(text)\(text.contains("@") ? "" : "@")\(title)"
        let _ = delegate?.textFieldShouldReturn?(self)
    }
}

fileprivate extension UIToolbar {
    var suggestedDomains: [String] {
        get {
            return items?.compactMap{$0.title} ?? []
        }
        set {
            guard newValue.isEmpty == false else {
                items = nil
                return
            }
            items = newValue.map {
                return UIBarButtonItem(title: $0, style: .plain, target: nil, action: #selector(UITextField.suggestedDomainDidTap(item:)))
            }
        }
    }
}

extension FirstViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard emailValidator.legalCharacter(string: string) else {
            return false
        }
        let email = textField.replacedText(range: range, replacementString: string)
        textField.satisfy = emailValidator.isValid(email)
        let suggestedDomains = emailValidator.suggest(email)
        accessaryView.suggestedDomains = suggestedDomains
        accessaryView.items?.forEach({
            $0.target = textField
        })
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        accessaryView.suggestedDomains = []
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        defer {
            textField.resignFirstResponder()
        }
        guard let email = textField.text else {
            return true
        }
        emailValidator.satisfy(email) {
            textField.satisfy = $0
        }
        return true
    }
}

