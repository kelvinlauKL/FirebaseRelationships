//
//  SegueHandlerType.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
  associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
  func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
    performSegue(withIdentifier: identifier.rawValue, sender: sender)
  }
  
  func segueIdentifierFor(segue: UIStoryboardSegue) -> SegueIdentifier {
    guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else { fatalError("Invalid identifier supplied") }
    return segueIdentifier
  }
}
