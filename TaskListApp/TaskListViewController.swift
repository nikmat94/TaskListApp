//
//  ViewController.swift
//  TaskListApp
//
//  Created by Никита  on 12.05.2021.
//

import UIKit
import CoreData

protocol TaskViewControllereDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let cellID = "cell"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }

    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    private func showAlertUpdate(with title: String, and message: String, index: Int) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.update(task, index: index)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = self.taskList[index].title
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
           guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
           guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
           task.title = taskName
           taskList.append(task)
           
           let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
           tableView.insertRows(at: [cellIndex], with: .automatic)
           
           if context.hasChanges {
               do {
                   try context.save()
               } catch let error {
                   print(error.localizedDescription)
               }
           }
       }
    
    private func update(_ taskName: String, index: Int) {
        let cellIndex = IndexPath(row: index, section: 0)
        taskList[index].title = taskName
        tableView.reloadRows(at: [cellIndex], with: .automatic)
    
        if context.hasChanges {
               do {
                   try context.save()
               } catch let error {
                   print(error.localizedDescription)
               }
           }
       }
    
    private func delete(index: Int)-> UISwipeActionsConfiguration {
        let cellIndex = IndexPath(row: index, section: 0)
        let task = taskList[index]
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { _, _, complete in
            self.taskList.remove(at: index)
            self.context.delete(task)
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
            self.tableView.deleteRows(at: [cellIndex], with: .automatic)
                complete(true)
            }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
                   configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlertUpdate(with: "Update", and: "You can change your value", index: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        delete(index: indexPath.row)
    }
    
    
        
}

// MARK: - TaskViewControllereDelegate
extension TaskListViewController: TaskViewControllereDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}

