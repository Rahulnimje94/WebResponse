//
//  ViewController.swift
//  WenResponse
//
//  Created by Anand Nimje on 31/01/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

struct WebData {
    let body: String
    let title: String
    let id: Int
    let userId: Int
    
    init(withTitle title: String, andBody body: String, _ userId: Int, _ id: Int) {
        self.title = title
        self.body = body
        self.id = id
        self.userId = userId
    }
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var userListTableView: UITableView!
    
    let APIUrl: String = "https://jsonplaceholder.typicode.com/posts"
    
    var webResponseData: [WebData] = []
    
    @IBOutlet weak var pleaseWaitLabel: UILabel!
    @IBOutlet weak var activityInndicator: UIActivityIndicatorView!
        

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityInndicator.isHidden = true
        self.initialTableViewSetup()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.pleaseWaitLabel.isHidden = false
        self.activityInndicator.isHidden = false
        
        self.activityInndicator.startAnimating()
        
        self.callAPI()
    }
}

//MARK:- Helper methods
extension ViewController {
    
    func initialTableViewSetup() {
        
        self.userListTableView.estimatedRowHeight = 60.0
        self.userListTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func callAPI() {
        
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: self.APIUrl) {
            var urlRequest = URLRequest(url: url)
            
            urlRequest.timeoutInterval = 60.0
            urlRequest.httpMethod = "GET"
            
            let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if error == nil {
                    
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        if statusCode == 200 {
                            print("Server response Sucessful")
                            sleep(5)
                            self.parseJSONData(withData: data)
                            DispatchQueue.main.async {
                                self.pleaseWaitLabel.isHidden = true
                                self.activityInndicator.isHidden = true
                                
                                self.activityInndicator.stopAnimating()
                                
                                self.userListTableView.reloadData()
                            }
                        } else {
                            print("Server response Failed")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.pleaseWaitLabel.isHidden = true
                        self.activityInndicator.isHidden = true
                        
                        self.activityInndicator.stopAnimating()
                    }
                }
            })
            dataTask.resume()
        }
    }
    
    func parseJSONData(withData data: Data?) {
        guard let serverData = data else { return }
        do {
            if let jsonData = try JSONSerialization.jsonObject(with: serverData, options: .mutableContainers) as? [[String: AnyObject]] {
                print("JSON Data is: \(jsonData)")
                
                for object in jsonData {
                    if let title = object["title"] as? String,
                        let body = object["body"] as? String,
                        let userId = object["userId"] as? Int,
                        let id = object["id"] as? Int {
                        
                        let responseObject = WebData(withTitle: title, andBody: body, userId, id)
                        self.webResponseData.append(responseObject)
                    }
                }
            }
            
        } catch let error {
            print("error Parsing Data: \(error.localizedDescription)")
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.webResponseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell
        let webObject = self.webResponseData[indexPath.row]
        cell?.titlelabel.text = webObject.title
        cell?.bodyLabel.text = webObject.body
        cell?.idLabel.text = webObject.id.description
        cell?.userIdLabel.text = webObject.userId.description
        return cell!
    }
}
