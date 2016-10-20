//
//  UserCell.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import UIKit

final class UserCell: UITableViewCell {
  static var reuseIdentifier = "\(UserCell.self)"
  
  var userId: String! { didSet {
    Server.loadUser(withIdentifier: userId) { user in
      if let user = user {
        self.textLabel?.text = user.name
        self.detailTextLabel?.text = "In \(user.groupIds.count) groups"
      }
    }
  }}
}
