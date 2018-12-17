//
//  EmailValidator.swift
//  EmailValidatorSwift
//
//  Created by Hyuk Hur on 2018-11-29.
//  Copyright © 2018 Hyuk Hur. All rights reserved.
//

import Foundation

protocol EmailPattern {
    func isValid(_ email: String) -> Bool
    var illegalCharacters: CharacterSet { get }
    func legalCharacter(string: String) -> Bool
}

extension EmailPattern {
    var illegalCharacters: CharacterSet {
        var illegalCharacters = CharacterSet.whitespacesAndNewlines
        illegalCharacters.insert(charactersIn: "://")
        return illegalCharacters
    }
    func legalCharacter(string: String) -> Bool {
        return string.rangeOfCharacter(from: self.illegalCharacters) == nil
    }
}

protocol EmailSuggestable {
    func suggest(_ email: String) -> [String]
}

protocol EmailDeliverable {
    func deliver(_ email: String, completion: @escaping (_ success: Bool, _ askedEmail: String) -> Void)
}

protocol EmailValidate: EmailPattern, EmailSuggestable, EmailDeliverable {
    func verify(_ email: String) -> (Bool, [String])
    func satisfy(_ email: String, completion: @escaping (_ success: Bool) -> Void)
}

/**
 * https://www.regular-expressions.info/email.html
 */
struct EmailRegularExpressionPattern: EmailPattern {
    static let emailPattern = (
        RFC1035 : "\\A(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*" +
            "| \"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]" +
            "| \\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")" +
            "@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?" +
            "| \\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}" +
            "(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:" +
            "(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]" +
            "|\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)" +
        "\\])\\z",

        modifiedRFC1035 : "\\A(?=[a-z0-9@.!#$%&'*+/=?^_`{|}~-]{6,254}\\z)" +
            "(?=[a-z0-9.!#$%&'*+/=?^_`{|}~-]{1,64}@)" +
            "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*" +
            "@ (?:(?=[a-z0-9-]{1,63}\\.)[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+" +
        "(?=[a-z0-9-]{1,63}\\z)[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\z",

        most: "\\A[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@" +
        "(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\z"
    )

    let regularExplress: NSRegularExpression? = {
        try? NSRegularExpression(pattern: EmailRegularExpressionPattern.emailPattern.RFC1035, options: [.caseInsensitive])
    }()

    func isValid(_ email: String) -> Bool {
        if let _ = regularExplress?.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) {
            return true
        }
        return false
    }
}

struct EmailUrlPattern: EmailPattern {
    func isValid(_ email: String) -> Bool {
        let urlString = email.contains(":\\") ? email : "email://\(email)"
        guard let url = URLComponents(string: urlString) else {
            return false
        }
        if url.port != nil {
            return false
        }
        guard [url.host, url.user].compactMap({ $0?.isEmpty }).filter({!$0}).count == 2 else {
            return false
        }
        guard let host = url.host else {
            return false
        }
        let hostWords = host.split(separator: ".", omittingEmptySubsequences: false)
        guard hostWords.count > 1 && hostWords.filter(({$0.isEmpty})).isEmpty else {
            return false
        }
        guard host.contains(where: {"!@#$%$%^&*()".contains($0)}) == false else {
            return false
        }
        if [url.fragment, url.password, url.query, url.path].compactMap({ $0?.isEmpty }).filter({!$0}).count > 0 {
            return false
        }
        return true
    }
}

struct EmailPresetSuggestor: EmailSuggestable {
    var preset: [String]
    func suggest(_ email: String) -> [String] {
        guard email.isEmpty == false && email.contains("@") else {
            return []
        }
        let userAndDomain = email.userAndDomain
        guard userAndDomain.user.isEmpty == false else {
            return []
        }
        if userAndDomain.domain.isEmpty {
            return preset
        }
        return preset.filter({
            return $0.hasPrefix(userAndDomain.domain) && $0 != userAndDomain.domain
        })
    }
}

fileprivate extension String {
    var userAndDomain: (user: String, domain: String) {
        let splitedEmail = split(separator: "@", omittingEmptySubsequences: false)
        let user = (splitedEmail.first) == nil ? self : String(splitedEmail.first!)
        let host = splitedEmail.last == nil ? self : String(splitedEmail.last!)
        return (user, host)
    }
}

/**
 https://docs.kickbox.com/docs/sandbox-api
 */
struct EmailKickboxDeliver: EmailDeliverable {
    let apiKey = "test_4fa8d4105abceda750ee8da3e1287744a54005b948e020e05f5c605fa36dddc4"

    static let allowedQueryParamAndKey = { () -> CharacterSet in
        var cs = CharacterSet.urlQueryAllowed
        cs.remove(charactersIn: ";/?:@&=+$")
        return cs
    }()

    func requestValidation(_ email: String, session: URLSession = URLSession.shared,  completion: @escaping (_: Bool, _: String, _: String) -> Void) {
        let local = email.userAndDomain
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: EmailKickboxDeliver.allowedQueryParamAndKey) ?? email
        let urlString = "https://api.kickbox.com/v2/verify?email=\(encodedEmail)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(false, local.user, local.domain)
            return
        }
        session.delegateQueue.cancelAllOperations()
        session.dataTask(with: url) { (data, response, error) in
            if let _ = error, data == nil {
                completion(false, local.user, local.domain)
                return
            }
            guard let json: [String: Any] = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: Any],
                let success = json["success"] as? Bool, success == true else {
                    completion(false, local.user, local.domain)
                    return
            }
            let deliverable = (json["result"] as? String) == "deliverable"
            let userFromServer = (json["user"] as? String) ?? local.user
            let domainFromServer = (json["domain"] as? String) ?? local.domain
            print(json)
            completion(deliverable, userFromServer, domainFromServer)
        }.resume()
    }

    func deliver(_ email: String, completion: @escaping (Bool, String) -> Void) {
        requestValidation(email) { success, user, domain in
            DispatchQueue.main.async {
                completion(success, "\(user)@\(domain)")
            }
        }
    }
}

/**

 */
struct EmailURLRequestDeliver: EmailDeliverable {
    func ipAddresses(_ domain: String) -> [String] {
        let host = CFHostCreateWithName(nil, domain as CFString).takeRetainedValue()
        var error: CFStreamError = CFStreamError()
        var success: DarwinBoolean = false
        CFHostStartInfoResolution(host, CFHostInfoType.addresses, &error)
        guard let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? else {
            return [String]()
        }
        return addresses.compactMap({
            guard let address = $0 as? NSData else {
                return nil
            }
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(address.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(address.length),
                              &hostname, socklen_t(hostname.count),
                              nil, 0,
                              NI_NUMERICHOST) == 0 else {
                                return nil
            }
            return String(cString: hostname)
        })
    }

    func hostAlive(domain: String, completion: (Bool) -> Void) {
        return completion(ipAddresses(domain).count > 0)
    }

    func deliver(_ email: String, completion: @escaping (Bool, String) -> Void) {
        let local = email.userAndDomain
        hostAlive(domain: local.domain, completion: { success in
            DispatchQueue.main.async {
                completion(success, local.domain)
            }
        })
    }
}

class EmailCachedDeliver: EmailDeliverable {
    let deliver: EmailDeliverable
    var expireCount: Int?
    var cache = [String: (deliverable: Bool, count: Int)]()

    init(deliver: EmailDeliverable, expireCount: Int? = 3) {
        self.deliver = deliver
        self.expireCount = expireCount
    }

    private func updateCache(deliverable: Bool, key: String) {
        let count = (self.cache[key]?.count ?? 0) + 1
        if let expireCount = self.expireCount, count >= expireCount {
            clear(cacheKey: key)
        } else {
            self.cache[key] = (deliverable, count)
        }
    }

    func deliver(_ email: String, completion: @escaping (Bool, String) -> Void) {
        if let cached = cache[email] ?? cache[email.userAndDomain.domain] {
            self.updateCache(deliverable: cached.deliverable, key: email)
            completion(cached.deliverable, email)
            return
        }
        deliver.deliver(email) {
            self.updateCache(deliverable: $0, key: $1)
            completion($0, $1)
        }
    }

    func isHit(cacheKey: String) -> Bool {
        return cache.keys.contains(cacheKey)
    }

    func clear(cacheKey: String) {
        let _ = cache.removeValue(forKey: cacheKey)
    }

    func clearAll() {
        cache.removeAll()
    }
}

struct EmailValidator: EmailValidate {
    let pattern: EmailPattern
    let suggest: EmailSuggestable
    let deliver: EmailDeliverable

    var illegalCharacters: CharacterSet {
        return pattern.illegalCharacters
    }

    func isValid(_ email: String) -> Bool {
        return pattern.isValid(email)
    }

    func deliver(_ email: String, completion: @escaping (Bool, String) -> Void) {
        return deliver.deliver(email, completion: completion)
    }

    func suggest(_ email: String) -> [String] {
        return suggest.suggest(email)
    }

    func verify(_ email: String) -> (Bool, [String]) {
        if isValid(email) {
            return (true, [])
        } else {
            return (false, suggest.suggest(email))
        }
    }

    func satisfy(_ email: String, completion: @escaping (Bool) -> Void) {
        guard isValid(email) else {
            completion(false)
            return
        }
        self.deliver(email) {
            print($1)
            completion($0)
        }
    }

    static let regExAndKickbox: EmailValidator = EmailValidator(pattern: EmailRegularExpressionPattern(),
                                                                suggest: EmailPresetSuggestor(preset: ["gmail.com", "yahoo.com", "ymail.com", "yahoo.co.uk", "gmail.co.uk", "yahoo.ca", "gmail.ca", "github.com"]),
                                                                deliver: EmailKickboxDeliver())
    static let urlAgent: EmailValidator = EmailValidator(pattern: EmailUrlPattern(),
                                                         suggest: EmailPresetSuggestor(preset: ["gmail.com", "yahoo.com", "ymail.com", "yahoo.co.uk", "gmail.co.uk", "yahoo.ca", "gmail.ca", "github.com"]),
                                                         deliver: EmailURLRequestDeliver())
}
