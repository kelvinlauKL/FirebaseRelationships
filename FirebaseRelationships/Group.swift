//
//  Group.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import Foundation
import Firebase

struct Group {
  var uid: String
  var name: String
  var userIds: [String]
  
  init(uid: String = Server.generateRandomId(), name: String, userIds: [String] = []) {
    self.uid = uid
    self.name = name
    self.userIds = userIds
  }
}

// MARK: - Mutating Methods
extension Group {
  mutating func add(user: User) {
    userIds.append(user.uid)
  }
}

// MARK: - FirebaseConvertible
extension Group: FirebaseConvertible {
  var json: [String: Any] {
    return [
      "uid": uid,
      "name": name,
      "userIds": userIds
    ]
  }
  
  init(dictionary: [String: Any]) {
    guard let uid = dictionary["uid"] as? String else { fatalError() }
    self.uid = uid
    
    guard let name = dictionary["name"] as? String else { fatalError() }
    self.name = name
    
    guard let userIds = dictionary["userIds"] as? [String] else {
      self.userIds = []
      return
    }
    
    self.userIds = userIds
  }
}

// MARK: Equatable 
extension Group: Equatable {}

func ==(lhs: Group, rhs: Group) -> Bool {
  return lhs.uid == rhs.uid
}
