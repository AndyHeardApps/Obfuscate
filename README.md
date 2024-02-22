# Obfuscate

This package contains two macros that assist in obfuscating in app secrets. It encryptes `String` secrets using either a randomly generated or explicitly provided symmetric key.

## Generated key

If no key is specified, then the macro will randomly create one for you and store it as bytes alongside the encrypted `String` value bytes. e.g.

```swift
let mySecret = #obfuscate("superSecretKey")
```

The above code expands to:

```swift
let mySecret = {
    let data = Data([23, 67, 52, 74, 189, 29, 184, 224, 122, 6, 247, 31, 62, 165, 241, 127, 114, 119, 195, 122, 107, 93, 107, 238, 135, 124, 182, 83, 35, 70, 164, 183, 96, 5, 170, 254, 166, 127, 102, 171, 239, 40])
    let keyData = Data([31, 2, 240, 155, 21, 111, 90, 81, 206, 187, 223, 233, 252, 191, 240, 158, 140, 208, 41, 243, 185, 91, 73, 17, 40, 191, 145, 121, 210, 252, 12, 48])
    let key = SymmetricKey(data: keyData)

    let decryptedData = try! AES.GCM.open(.init(combined: data), using: key)

    return String(data: decryptedData, encoding: .utf8)!
}()
```

Storing the data as bytes helps defend against string extraction tools, and adds friction for any attacker.

The potential issue here is that the key data is stored alongside the encrypted data, so more advanced attacks could read both and proceed to decrypt the secret. An alternative to this is to declare an explicit key that is stored outside of the app, and fetch it at runtime.

## Explicit key

To use an explicitly defined key for encryption, pass the Base-64 representation of the key data into the macro:

```swift
let mySecret = #obfuscate("superSecretKey", key: "PapYT8nL1T4EJQPxejHdf0D8yUzJ75UTEcu5A83zoBU=")
```

This expands to:

```swift
let mySecret = { (keyBase64: String) throws -> String in
    let encryptedData = Data([194, 1, 214, 246, 254, 171, 155, 131, 71, 11, 102, 232, 93, 49, 82, 194, 60, 101, 85, 144, 237, 237, 68, 158, 149, 4, 65, 78, 173, 141, 6, 83, 150, 191, 36, 221, 171, 60, 127, 244, 166, 232])

    guard let keyData = Data(base64Encoded: keyBase64) else {
        throw ObfuscateError.invalidKeyBase64
    }
    let key = SymmetricKey(data: keyData)

    let decryptedData = try AES.GCM.open(.init(combined: encryptedData), using: key)

    guard let decryptedValue = String(data: decryptedData, encoding: .utf8) else {
        throw ObfuscateError.invalidDecryptedValueData
    }

    return decryptedValue
}
```

The macro converts the provided static `String` into a `(String) throws -> String` closure. In order to to decrypt and use the original value, call this closure providing the same key Base-64 representation.

```swift
let keyBase64 = try await server.fetchKeyBase64() // "PapYT8nL1T4EJQPxejHdf0D8yUzJ75UTEcu5A83zoBU="
let decryptedSecret = try mySecret(keyBase64)
```

This allows you to store the value of the key elsewhere and provide it at runtime instead of at compile time, helping improve the security of the app binary.
