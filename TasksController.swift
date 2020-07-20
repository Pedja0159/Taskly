//
//  TasksController.swift
//  Taskly
//
//  Created by Predrag on 15/04/2020.
//  Copyright © 2020 pejo015. All rights reserved.
//

import UIKit

class TasksController: UITableViewController {
    
    
    var taskStore = TaskStore() {
        
        didSet {
            
            taskStore.tasks = TaskUtility.fetch() ?? [[Task](), [Task]()]
            
            tableView.reloadData()
            
        }
        
        
        
    }
    
    
    lazy var mainImageView: UIImageView = {
        
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        
        
    }
    
    
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "add", style: .default) { _ in
            
            guard let name = alertController.textFields?.first?.text else { return }
            
            let newTask = Task(name: name)
            
            self.taskStore.add(newTask, at: 0)
            
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
            
            TaskUtility.save(self.taskStore.tasks)
            
            
            
        }
        addAction.isEnabled = true
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel)
        
        alertController.addTextField { textField in
            
            textField.placeholder = "Enter task name..."
            textField.addTarget(self, action: #selector(self.handleTextChanged), for: .editingChanged)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancleAction)
        
        
        present(alertController, animated: true)
        
    }
    
    @objc private func handleTextChanged(_ sender: UITextField) {
        
        guard let alertController = present as? UIAlertController,
            let addAction = alertController.actions.first,
            let text = sender.text
            else { return }
        
        
        addAction.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
}


extension TasksController {
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return section == 0 ? "To-do" : "Done"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return taskStore.tasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskStore.tasks[section].count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = taskStore.tasks[indexPath.section][indexPath.row].name
        return cell
    }
    
}

extension TasksController {
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        54
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {(action, sourceView,completionHandler) in
            
            guard let isDone = self.taskStore.tasks[indexPath.section][indexPath.row].isDone else { return }
            self.taskStore.removeTask(at: indexPath.row, isDone: isDone)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            
            TaskUtility.save(self.taskStore.tasks)
            
            
            completionHandler(true)
            
        }
        deleteAction.image = #imageLiteral(resourceName: "delete")
        deleteAction.backgroundColor = #colorLiteral(red: 0.8862745098, green: 0.1450980392, blue: 0.168627451, alpha: 1)
        
        
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let doneAction = UIContextualAction(style: .normal, title: nil) {(action,sourceView,completionHandler) in
            
            self.taskStore.tasks[0][indexPath.row].isDone = true
            let doneTask = self.taskStore.removeTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.taskStore.add(doneTask, at: 0, isDone: true)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            
            
            TaskUtility.save(self.taskStore.tasks)
            
            completionHandler(true)
            
        }
        
        doneAction.image = #imageLiteral(resourceName: "done")
        doneAction.backgroundColor = #colorLiteral(red: 0.01176470588, green: 0.7529411765, blue: 0.2901960784, alpha: 1)
        
        return indexPath.section == 0 ?  UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
    
    
    
}
