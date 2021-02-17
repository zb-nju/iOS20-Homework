//
//  BusinessProcessViewController.swift
//  NJUNews
//
//  Created by CuiZihan on 2020/12/23.
//

import UIKit
import os.log
import SwiftSoup

class WorkFlowViewController: UIViewController {
    //MARK: Properties
    var newsList = [News]()
    var mainURL = "https://jw.nju.edu.cn"
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fetchData()
    }
    
    //MARK: Nevigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let workFlowContentViewController = segue.destination as? WorkFlowContentViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedNewsCell = sender as? WorkFlowTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedNewsCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedNews = newsList[indexPath.row]
            workFlowContentViewController.news = selectedNews
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
}

extension WorkFlowViewController: UITableViewDelegate, UITableViewDataSource{
    //MARK: Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkFlowCell") as! WorkFlowTableViewCell
        let news = newsList[indexPath.row]
        cell.textLabel?.text = "[" + news.date + "]" + news.title
        return cell
    }
}

extension WorkFlowViewController{
    //MARK: Fetch Data
    func fetchData() {
        let url = URL(string: mainURL + "/_s414/24739/list.psp")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }

            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        do{
                            let doc : Document = try SwiftSoup.parse(string)
                            let rawNewsList : Elements = try doc.getElementsByClass("news")
                            //print(try news.first()?.html())
                            for news in rawNewsList {
                                let title = try news.select("a").attr("title")
                                let URL = try news.select("a").attr("href")
                                let date = try news.select("span.news_meta").text()
                                guard let teachingNews = News(title: title, URL: self.mainURL + URL, date: date) else {
                                    fatalError("Unable to instantiate TeachingNews")
                                }
                                self.newsList += [teachingNews]
                            }
                            self.tableView.reloadData()
                        }catch Exception.Error(_, let message) {
                            print(message)
                        } catch {
                            print("error")
                        }
                    }
                }
            }
        )

        task.resume()
    }
}
