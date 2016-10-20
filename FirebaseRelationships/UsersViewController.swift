//
//  UsersViewController.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import UIKit
import Firebase

final class UsersViewController: UIViewController {
  @IBOutlet fileprivate var tableView: UITableView!
  
  fileprivate var users: [User] = []
  
  fileprivate let usersRef = FIRDatabase.database().reference().child("users")
  
  /// These are observers that are created in the `viewDidLoad` method. All handles must be removed when the view controller deinits.
  fileprivate var handles: [FIRDatabaseHandle] = []
  
  deinit {
    handles.forEach {
      usersRef.removeObserver(withHandle: $0)
    }
  }
}

// MARK: - Life Cycle
extension UsersViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let childAddedHandle = usersRef.observe(.childAdded, with: { snapshot in
      guard let userDict = snapshot.value as? [String: Any] else { return print("couldn't cast") }
      let user = User(dictionary: userDict)
      self.users.append(user)
      self.tableView.insertRows(at: [IndexPath(row: self.users.count - 1, section: 0)], with: .automatic)
    })
    
    let childChangedHandle = usersRef.observe(.childChanged, with: { snapshot in
      guard let userDict = snapshot.value as? [String: Any] else { return print("couldn't cast child changed") }
      let newUser = User(dictionary: userDict)
      guard let index = self.users.index(of: newUser) else { fatalError() }
      self.users[index] = newUser
      
      let indexPath = IndexPath(row: index, section: 0)
      self.tableView.reloadRows(at: [indexPath], with: .automatic)
    })
    
    handles.append(contentsOf: [childAddedHandle, childChangedHandle])
  }
}

// MARK: - UITableViewDataSource
extension UsersViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = users[indexPath.row].name
    cell.detailTextLabel?.text = "In \(users[indexPath.row].groupIds.count) groups"
    return cell
  }
}

// MARK: - UITableViewDelegate
extension UsersViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: @IBActions
private extension UsersViewController {
  @IBAction func addButtonTapped() {
    let alertController = UIAlertController(title: "New User", message: nil, preferredStyle: .alert)
    
    alertController.addTextField { textField in
      textField.placeholder = "User's name"
    }
    
    let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
      guard let text = alertController.textFields?[0].text else { fatalError() }
      let user = User(name: text)
      Server.save(user: user)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
}
