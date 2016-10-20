//
//  AddMembersViewController.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import UIKit
import Firebase

final class AddMembersViewController: UIViewController {
  @IBOutlet fileprivate var tableView: UITableView!
  
  var group: Group!
  
  fileprivate var users: [User] = []
  fileprivate var isChecked: [Bool] = []
}

// MARK: - Life Cycle
extension AddMembersViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let usersRef = FIRDatabase.database().reference().child("users")
    
    usersRef.observe(.childAdded, with: { snapshot in
      guard let userDict = snapshot.value as? [String: Any] else { return print("couldn't cast") }
      let user = User(dictionary: userDict)
      guard !user.groupIds.contains(self.group.uid) else { return print("already in the group") }
      
      self.users.append(user)
      self.isChecked.append(false)
      self.tableView.insertRows(at: [IndexPath(row: self.users.count - 1, section: 0)], with: .automatic)
    })
  }
}

// MARK: - UITableViewDataSource
extension AddMembersViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = users[indexPath.row].name
    cell.detailTextLabel?.text = "In \(users[indexPath.row].groupIds.count) groups"
    
    if isChecked[indexPath.row] {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension AddMembersViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    isChecked[indexPath.row] = !isChecked[indexPath.row]
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
}

// MARK: - @IBActions
private extension AddMembersViewController {
  @IBAction func cancelButtonTapped() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonTapped() {
    for (index, checked) in isChecked.enumerated() {
      if checked {
        var user = users[index]
        group.add(user: users[index])
        user.add(group: group)
        Server.save(user: user)
      }
    }
    
    Server.save(group: group)
    
    navigationController?.dismiss(animated: true, completion: nil)
  }
}
