//
//  User.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import Foundation
import Firebase

struct User {
  var uid: String
  var name: String
  var groupIds: [String]
  
  init(uid: String = Server.generateRandomId(), name: String, groupIds: [String] = []) {
    self.uid = uid
    self.name = name
    self.groupIds = groupIds
  }
}

// MARK: - Mutating Methods
extension User {
  mutating func add(group: Group) {
    groupIds.append(group.uid)
  }
}

// MARK: - FirebaseConvertible 
extension User: FirebaseConvertible {
  var json: [String: Any] {
    return [
      "uid": uid,
      "name": name,
      "groupIds": groupIds
    ]
  }
  
  init(dictionary: [String: Any]) {
    guard let uid = dictionary["uid"] as? String else { fatalError() }
    self.uid = uid
    
    guard let name = dictionary["name"] as? String else { fatalError() }
    self.name = name
    
    guard let groupIds = dictionary["groupIds"] as? [String] else {
      self.groupIds = []
      return
    }
    self.groupIds = groupIds
  }
}

extension User: Equatable {}

func ==(lhs: User, rhs: User) -> Bool {
  return lhs.uid == rhs.uid
}
