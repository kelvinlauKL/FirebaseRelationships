//
//  GroupsViewController.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import UIKit
import Firebase

final class GroupsViewController: UIViewController {
  @IBOutlet fileprivate var tableView: UITableView!
  fileprivate var groups: [Group] = []
  
  fileprivate let groupsRef = FIRDatabase.database().reference().child("groups")
  
  /// These are observers that are created in the `viewDidLoad` method. All handles must be removed when the view controller deinits.
  fileprivate var handles: [FIRDatabaseHandle] = []
}

// MARK: - Life Cycle
extension GroupsViewController {
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let childAddedHandle = groupsRef.observe(.childAdded, with: { snapshot in
      guard let groupDict = snapshot.value as? [String: Any] else { return print("couldn't cast") }
      let group = Group(dictionary: groupDict)
      self.groups.append(group)
      self.tableView.insertRows(at: [IndexPath(row: self.groups.count - 1, section: 0)], with: .automatic)
    })
    
    let childChangedHandle = groupsRef.observe(.childChanged, with: { snapshot in
      guard let groupDict = snapshot.value as? [String: Any] else { return print("couldn't cast child changed") }
      let newGroup = Group(dictionary: groupDict)
      guard let index = self.groups.index(of: newGroup) else { fatalError() }
      self.groups[index] = newGroup
      let indexPath = IndexPath(row: index, section: 0)
      self.tableView.reloadRows(at: [indexPath], with: .automatic)
    })
    
    handles.append(contentsOf: [childAddedHandle, childChangedHandle])
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    handles.forEach {
      groupsRef.removeObserver(withHandle: $0)
    }
  }
}

// MARK: - SegueHandlerType
extension GroupsViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case groupMembers
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifierFor(segue: segue) {
    case .groupMembers:
      guard let groupMembersViewController = segue.destination as? GroupMembersViewController else { fatalError() }
      groupMembersViewController.group = sender as! Group
    }
  }
}


// MARK: - UITableViewDataSource
extension GroupsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groups.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = groups[indexPath.row].name
    cell.detailTextLabel?.text = "# of participants: \(groups[indexPath.row].userIds.count)"
    return cell
  }
}

// MARK: - UITableViewDelegate
extension GroupsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    performSegue(withIdentifier: .groupMembers, sender: groups[indexPath.row])
  }
}

// MARK: - @IBActions
private extension GroupsViewController {
  @IBAction func addButtonTapped() {
    let alertController = UIAlertController(title: "New Group", message: nil, preferredStyle: .alert)
    
    alertController.addTextField { textField in
      textField.placeholder = "Group name"
    }
    
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      guard let name = alertController.textFields?[0].text else { fatalError() }
      let group = Group(name: name)
      print(group.uid)
      Server.save(group: group)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)

    present(alertController, animated: true, completion: nil)
  }
}
