//
//  String+Extension.swift
//  Pods-samplePod_Example
//
//  Created by Coruscate on 07/02/19.
//

import UIKit

extension String {
    
    func firstCharacterCapitalized() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

