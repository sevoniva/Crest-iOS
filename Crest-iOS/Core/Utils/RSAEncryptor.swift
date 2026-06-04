import Foundation
import Security

enum RSAEncryptor {
    static func encrypt(string: String, publicKey: String) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let keyString = publicKey
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let keyData = Data(base64Encoded: keyString) else { return nil }
        
        let tag = "com.sevoniva.crest.tempkey"
        let tagData = tag.data(using: .utf8)!
        
        SecItemDelete([
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tagData
        ] as CFDictionary)
        
        let keyDict: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag as String: tagData,
            kSecValueData as String: keyData,
            kSecAttrKeySizeInBits as String: 2048,
            kSecReturnRef as String: true
        ]
        
        var result: SecKey?
        let status = SecItemAdd(keyDict as CFDictionary, &result)
        
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            if status == errSecDuplicateItem {
                let getQuery: [String: Any] = [
                    kSecClass as String: kSecClassKey,
                    kSecAttrApplicationTag as String: tagData,
                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                    kSecReturnRef as String: true
                ]
                SecItemCopyMatching(getQuery as CFDictionary, &result)
            }
            return nil
        }
        
        guard let publicSecKey = result else { return nil }
        
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicSecKey,
            .rsaEncryptionPKCS1,
            data as CFData,
            nil
        ) else {
            SecItemDelete([kSecClass as String: kSecClassKey, kSecAttrApplicationTag as String: tagData] as CFDictionary)
            return nil
        }
        
        SecItemDelete([kSecClass as String: kSecClassKey, kSecAttrApplicationTag as String: tagData] as CFDictionary)
        
        return (encryptedData as Data).base64EncodedString()
    }
}
