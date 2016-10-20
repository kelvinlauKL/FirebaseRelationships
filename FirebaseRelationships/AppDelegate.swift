//
//  AppDelegate.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
final class AppDelegate: UIResponder {
  var window: UIWindow?
  
  override init() {
    super.init()
    FIRApp.configure()
  }
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {}

