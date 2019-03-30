# samplePod

[![CI Status](https://img.shields.io/travis/Mayuramipara94/samplePod.svg?style=flat)](https://travis-ci.org/Mayuramipara94/samplePod)
[![Version](https://img.shields.io/cocoapods/v/samplePod.svg?style=flat)](https://cocoapods.org/pods/samplePod)
[![License](https://img.shields.io/cocoapods/l/samplePod.svg?style=flat)](https://cocoapods.org/pods/samplePod)
[![Platform](https://img.shields.io/cocoapods/p/samplePod.svg?style=flat)](https://cocoapods.org/pods/samplePod)

## Example

    To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10.0+ | Xcode 10.0+ | Swift 4.2+

## Installation

samplePod is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'samplePod'
```

## Author

Mayuramipara94, mayur.amipara@coruscate.co.in

## Description

    public func toDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.number(from: self) as? Double
    }
    
    public func toInt() -> Int? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self) as? Int
    }
    
    public func formatValue() -> String {
        
        let value = Double(self) ?? 0.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let formattedAmount = formatter.string(from: value as NSNumber)
        if formattedAmount == "0.00"{
            return "-"
        }
        return formattedAmount ?? "-"
    }
    
    public func isNumeric() -> Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        return  !hasLetters && hasNumbers
    }
    
    public func isValidPassword() -> Bool {
        
        let regExpression = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExpression)
        return predicate.evaluate(with:self)
    }
    
    
    /// Check for email validation
    public func isValidEmail() -> Bool {
        
        let str = self.removeWhiteSpaces()
        let regExpression = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,25}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExpression)
        return predicate.evaluate(with:str)
    }
    
    
    /// Check for mobile validation
    public func isValidMobileNumber() -> Bool{
        
        let phoneRegex: String = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if phoneTest.evaluate(with: self) {
            if CInt(self) != 0 {
                return true
            }
        }
        return false
    }
    
    /// Check for mobile validation
    public func isValidPincode() -> Bool{
        
        let pincodeRegex: String = "^[0-9]{4}$"
        let pincodeTest = NSPredicate(format: "SELF MATCHES %@", pincodeRegex)
        if pincodeTest.evaluate(with: self) {
            if CInt(self) != 0 {
                return true
            }
        }
        return false
    }
    
    /// Remove white spaces (front and rear) from string
    public func removeWhiteSpaces () -> String {
        var str = self.trimmingCharacters(in: .whitespaces)
        str = str.replacingOccurrences(of: " ", with: "")
        return str
    }
    
    /// Check if value is 0/1 or Yes/No or Y/N
    public func boolValue() -> Bool {
        
        switch self {
        case "True", "true", "yes", "Yes", "1":
            return true
        case "False", "false", "no", "No", "0":
            return false
        default:
            return false
        }
    }
    
    public subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    public subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        let range: Range<Index> = start ..< end
        //return String(self[Range(start ..< end)])
        return String(self[range])
    }
    
    /// Get document directory path url for given string
    public static func documentDirectoryPath(forFileName name:String) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = paths.first! as NSString
        return documentPath.appendingPathComponent(name) as String
    }
    
    public func fileExtension() -> String {
        
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
    
    public func fileName() -> String {
        
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }
    
    public var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    
    public func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    public mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    //Chat Methods
    
    public func isVideo() -> Bool {
        
        if self.fileExtension().lowercased() == "webm" || self.fileExtension().lowercased() == "mkv" || self.fileExtension().lowercased() == "3gp" || self.fileExtension().lowercased() == "m4v" || self.fileExtension().lowercased() == "mp4" || self.fileExtension().lowercased() == "mov" {
            
            return true
        }
        
        return false
    }

## License

samplePod is available under the MIT license. See the LICENSE file for more info.
