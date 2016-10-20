//
//  Server+Database.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import Firebase

protocol FirebaseConvertible {
  var json: [String: Any] { get }
  
  init(dictionary: [String: Any])
}

extension Server {
  private static var rootRef: FIRDatabaseReference {
    return FIRDatabase.database().reference()
  }
  
  private static var usersRef: FIRDatabaseReference {
    return Server.rootRef.child("users")
  }
  
  private static var groupsRef: FIRDatabaseReference {
    return Server.rootRef.child("groups")
  }
  
  static func generateRandomId() -> String {
    return Server.rootRef.childByAutoId().key
  }
  
  static func loadUser(withIdentifier identifier: String, completion: @escaping (User?) -> ()) {
    Server.usersRef.child(identifier).observeSingleEvent(of: .value, with: { snapshot in
      guard let userDict = snapshot.value as? [String: Any] else { return completion(nil) }
      let user = User(dictionary: userDict)
      
      DispatchQueue.main.async {
        completion(user)
      }
    })
  }
  
  static func loadGroup(withIdentifier identifier: String, completion: @escaping (Group?) -> ()) {
    Server.groupsRef.child(identifier).observeSingleEvent(of: .value, with: { snapshot in
      guard let groupDict = snapshot.value as? [String: Any] else { return completion(nil) }
      let group = Group(dictionary: groupDict)
      
      DispatchQueue.main.async {
        completion(group)
      }
    })
  }
  
  static func save(user: User) {
    Server.usersRef.child(user.uid).setValue(user.json)
  }
  
  static func save(group: Group) {
    Server.groupsRef.child(group.uid).setValue(group.json)
  }
}
