//
//  Security.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

let kSparkSetupSecurityPublicKeystore = "kSparkSetupSecurityPublicKeystore"

enum SecurityError: Error {
    case parseError(message: String)
    case keychainWriteFailure
    case stringDecodeFailure
    case publicKeyNotFound
}

struct Security {
    public static func decode(fromHexString string: String) throws -> Data? {
        return String.decode(fromHexString: string)
    }
    
    public static func encode(toHexString data: Data) throws -> String? {
        return Data.encode(toHexString: data)
    }
    
    public static func getPublicKey() throws -> SecKey? {
        var keyAttr = [String: Any]()
        
        let refTag = Data(bytes: kSparkSetupSecurityPublicKeystore, count: kSparkSetupSecurityPublicKeystore.count)
        
        keyAttr[String(kSecClass)] = kSecClassKey
        keyAttr[String(kSecAttrKeyType)] = kSecAttrKeyTypeRSA
        keyAttr[String(kSecAttrApplicationTag)] = refTag as CFData
        keyAttr[String(kSecReturnRef)] = true
        
        // Get the persistent key reference.
        var status: OSStatus = noErr
        var keyRef: AnyObject?
        status = SecItemCopyMatching(keyAttr as CFDictionary, &keyRef);
        
        if (keyRef == nil || ( status != noErr && status != errSecDuplicateItem)) {
            throw SecurityError.publicKeyNotFound
        }
        
        return keyRef as! SecKey?
    }
    
    public static func setPublicKey(data: Data) throws {
        do {
            let extractedKey = try SwiftyRSA.stripPublicKeyHeader(keyData: data)
            
            var status: OSStatus = noErr
            
            let refTag = Data(bytes: kSparkSetupSecurityPublicKeystore, count: kSparkSetupSecurityPublicKeystore.count)
            var keyAttr = [String: AnyObject]()
            
            keyAttr[String(kSecClass)] = kSecClassKey
            keyAttr[String(kSecAttrKeyType)] = kSecAttrKeyTypeRSA
            keyAttr[String(kSecAttrApplicationTag)] = refTag as CFData
            
            SecItemDelete(keyAttr as CFDictionary)
            
            keyAttr[String(kSecValueData)] = extractedKey as CFData
            keyAttr[String(kSecReturnPersistentRef)] = true as CFBoolean
            
            var persistRef: AnyObject?
            status = SecItemAdd(keyAttr as CFDictionary, &persistRef)
            
            if (persistRef == nil || (status != noErr && status != errSecDuplicateItem)) {
                print("Problem adding public key to keychain")
                throw SecurityError.keychainWriteFailure
            }
            
            keyAttr.removeAll()
            
            keyAttr[String(kSecClass)] = kSecClassKey
            keyAttr[String(kSecAttrKeyType)] = kSecAttrKeyTypeRSA
            keyAttr[String(kSecAttrApplicationTag)] = refTag as CFData
            keyAttr[String(kSecReturnRef)] = NSNumber(value: true)
            
            var retVal: AnyObject?
            status = SecItemCopyMatching(keyAttr as CFDictionary, &retVal)
            
            if (retVal == nil || (status != noErr && status != errSecDuplicateItem)) {
                print("Error retrieving public key reference from chain")
                throw SecurityError.keychainWriteFailure
            }
        } catch {
            throw SecurityError.keychainWriteFailure
        }
        
    }
    
    public static func encryptWith(publicKey: SecKey, plainText: Data) -> Data? {
        let padding: UInt32 = SecPadding.PKCS1.rawValue
        var cipherBufferSize = 128
        var cipherBuffer = [UInt8](repeating: 0, count: Int(cipherBufferSize))
        
        let keyBlockSize = SecKeyGetBlockSize(publicKey)
        
        if plainText.count > keyBlockSize {
            return nil
        }
        
        let bytes = plainText.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: plainText.count))
        }
        
        var status: OSStatus = noErr
        status = SecKeyEncrypt(publicKey, SecPadding(rawValue: padding), bytes, bytes.count, &cipherBuffer, &cipherBufferSize)
        
        
        var cipherText: Data
        if status == errSecSuccess {
            cipherText = Data(bytes: cipherBuffer, count: cipherBufferSize)
            return cipherText
        } else {
            return nil
        }
    }
}

extension String {
    public static func decode(fromHexString string: String) -> Data? {
        var data = Data(capacity: string.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: string, options: [], range: NSMakeRange(0, string.count)) { match, flags, stop in
            let byteString = (string as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)
            data.append(&num!, count: 1)
        }
        
        return data
    }
}

extension Data {
    public static func encode(toHexString data: Data) -> String? {
        return (data.map { String(format: "%02x", $0) }).joined(separator: "")
    }
}
