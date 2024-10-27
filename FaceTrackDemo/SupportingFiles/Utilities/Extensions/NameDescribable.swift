//
//  NameDescribable.swift
//  FaceTrackDemo
//
//  Created by Vishal Chandran on 27/10/24.
//

import Foundation

protocol NameDescribable {
    static var typeName: String { get }
}

extension NameDescribable {
    static var typeName: String {
        return String(describing: self)
    }
}
