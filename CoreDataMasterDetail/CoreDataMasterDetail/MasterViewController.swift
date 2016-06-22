//
//  MasterViewController.swift
//  MasterDetail-CoreData-1
//
//  Created by Jason on 3/9/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

/**
* Five steps to using Core Data to persist MasterDetail:
*
* 1. Add a convenience method that find the shared context
* 2. Add fetchAllEvents()
* 3. Invoke fetchAllevents in viewDidLoad()
* 4. Create an Event object in insertNewObject()
* 5. Save the context in insertNewObject()
*
*/

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var events = [Event]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        // Step 3: initialize the events array with the results of the fetchAllEvents() method
        events = fetchAllEvents()
    }
    
    func insertNewObject(sender: AnyObject) {
        
        // Step 4: Create an Event object (and append it to the events array.)
        
        let newEvent = Event(context: sharedContext)
        
        events.append(newEvent)
        
        // Step 5: Save the context (and check for an error)
        var error: NSError?
        
        do {
            try sharedContext.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = events[indexPath.row]
                (segue.destinationViewController as! DetailViewController).detailItem = object
            }
        }
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let event = events[indexPath.row]
        
        cell.textLabel!.text = event.timeStamp.description
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            if editingStyle == .Delete {
                // How do we delete a managed object? An interesting, open question.
            }
    }
    
    // MARK: - Core Data Fetch Helpers
    
    // Step 1: Add a "sharedContext" convenience property.
    var sharedContext: NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    // Step 2: Add a fetchAllEvents() method
    func fetchAllEvents() -> [Event] {
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: sharedContext)
        var error: NSError? = nil
        
        fetchRequest.entity = entity
        
        // This is a little bit fancy. Adding a sort descriptor to the fetch request
        // gives us some control over. We will see more ways to enhance fetch requests
        // in Lesson 4
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        
        if let error = error {
            print("Error fetching events: \(error)")
            return [Event]()
        }
        
        return results as! [Event]
    }
}

