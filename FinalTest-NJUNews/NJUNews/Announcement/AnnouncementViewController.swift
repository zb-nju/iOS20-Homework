//
//  AnnouncementViewController.swift
//  NJUNews
//
//  Created by CuiZihan on 2020/12/23.
//

import UIKit
import os.log
import SwiftSoup

class AnnouncementViewController: UIViewController {
    //MARK: Properties
    var shownNewsList = [News]()
    var newsList = [News]()
    var mainURL = "https://jw.nju.edu.cn"
    var searchTerms: [String: Set<News>] = [:]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.autocapitalizationType = .none
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
        // Do any additional setup after loading the view.
        fetchData()
        newsList.forEach{
            populateSearch($0)
        }
        shownNewsList = newsList
        tableView.reloadData()
    }
    

    //MARK: Nevigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let announcementContentViewController = segue.destination as? AnnouncementContentViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedNewsCell = sender as? AnnouncementTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedNewsCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedNews = newsList[indexPath.row]
            announcementContentViewController.news = selectedNews
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
}

extension AnnouncementViewController: UITableViewDelegate, UITableViewDataSource{
    //MARK: Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownNewsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell") as! AnnouncementTableViewCell
        let news = shownNewsList[indexPath.row]
        cell.textLabel?.text = "[" + news.date + "]" + news.title
        return cell
    }
}

extension AnnouncementViewController{
    //MARK: Fetch Data
    func fetchData() {
        let url = URL(string: mainURL + "/_s414/ggtz/list.psp")!
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
    
    private func populateSearch(_ news: News) {
      getSearchTerms(text: news.title, language: "zh") { word in
        guard var values = searchTerms[word] else {
          searchTerms[word] = Set([news])
          return
        }
        values.insert(news)
        searchTerms[word] = values
      }
    }
}

extension AnnouncementViewController: UISearchResultsUpdating{
    func filterContent(searchText: String){
        if searchText != ""{
            findMatches(searchText)
        }
        else{
            shownNewsList = newsList
        }
        tableView.reloadData()
    }
    
    func findMatches(_ searchText: String) {
      var matches: Set<News> = []
        print(Locale.current.languageCode!)
      getSearchTerms(text: searchText, language: "zh") { word in
          if let founds = searchTerms[searchText.lowercased()] {
            matches.formUnion(founds)
          }
      }
        print(matches)
      shownNewsList = matches.filter { newsList.contains($0) }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: searchController.searchBar.text!)
    }
}

extension AnnouncementViewController: UISearchControllerDelegate{
    func willDismissSearchController(_ searchController: UISearchController) {
        filterContent(searchText: "")
    }
}

