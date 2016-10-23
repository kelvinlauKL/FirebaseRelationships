//
//  GroupMembersViewController.swift
//  FirebaseRelationships
//
//  Created by Kelvin Lau on 2016-10-19.
//  Copyright © 2016 Kelvin Lau. All rights reserved.
//

import UIKit
import Firebase

final class GroupMembersViewController: UIViewController {
  @IBOutlet fileprivate var tableView: UITableView!
  var group: Group! { didSet { title = group.name }}
  
  fileprivate var groupRef: FIRDatabaseReference!
  
  fileprivate var handles: [FIRDatabaseHandle] = []
}

// MARK: - Life Cycle 
extension GroupMembersViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    groupRef = FIRDatabase.database().reference().child("groups").child(group.uid)
    

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let valueHandle = groupRef.observe(.value, with: { snapshot in
      guard let groupDict = snapshot.value as? [String: Any] else { return print("couldn't cast") }
      let group = Group(dictionary: groupDict)
      self.group = group
      self.tableView.reloadData()
    })
    
    handles.append(valueHandle)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    handles.forEach {
      groupRef.removeObserver(withHandle: $0)
    }
  }
}
// MARK: - SegueHandlerType
extension GroupMembersViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case addMembers
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifierFor(segue: segue) {
    case .addMembers:
      guard let naviVC = segue.destination as? UINavigationController, let addMembersVC = naviVC.topViewController as? AddMembersViewController else { fatalError() }
      addMembersVC.group = group
    }
  }
}

// MARK: - UITableViewDataSource
extension GroupMembersViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return group.userIds.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UserCell else { fatalError() }
    cell.userId = group.userIds[indexPath.row]
    return cell
  }
}

// MARK: - @IBActions
private extension GroupMembersViewController {
  @IBAction func addButtonTapped() {
    performSegue(withIdentifier: .addMembers, sender: nil)
  }
}
