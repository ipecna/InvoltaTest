//
//  ViewController.swift
//  InvoltaTest
//
//  Created by Semyon Chulkov on 13.01.2022.
//

import UIKit

class ViewController: UITableViewController {
    
    let networkManager = NetworkManager()
    var data = [String]()
    var reversedData = [String]()
    
    let refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refresh
        
        networkManager.delegate = self
        networkManager.fetchData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reversedData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = reversedData[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    @objc func refreshData() {
        networkManager.offset += 20
        networkManager.fetchData(with: networkManager.offset)
        refreshControl?.endRefreshing()
    }
    
    //this method allows us to identify the moment when user is near the top of the tableView and fetch data without pull to refresh
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("The current Y offset is \(scrollView.contentOffset.y)")
        let rowHeight = tableView.rowHeight
        //print(rowHeight)
        if scrollView.contentOffset.y <= -rowHeight {
            refreshData()
        }
    }
}

extension ViewController: NetworkManagerDelegate {
    
    func didLoadData(_ networkManager: NetworkManager, data: TestModel) {
        if data.messages.count > 0 {
            self.data += data.messages
            reversedData = self.data.reversed()
            tableView.reloadData()
            // this helps us to scroll from bottom, although not the best solution
            let indexPath = IndexPath(row: data.messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            
        } else {
            let ac = UIAlertController(title: "Sorry", message: "It seems there are no more messages", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true)
        }
    }
    
    func didFailWithError(error: Error) {
        let ac = UIAlertController(title: "Ooops!", message: "Let's try again?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.networkManager.fetchData(with: (self?.networkManager.offset)!)
            self?.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(ac, animated: true)
    }
}
