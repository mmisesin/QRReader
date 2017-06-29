//
//  InfoViewController.swift
//  QRReader
//
//  Created by Artem Misesin on 5/4/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit

extension InfoViewController: XMLParserDelegate{
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentValue != " "{
            currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName.contains("_id") {
            let tempItem = Item();
            tempItem.name = self.item.name;
            tempItem.price = self.item.price;
            tempItem.quantity = self.item.quantity;
            items.append(tempItem);
        } else if elementName == "name"{
            item.name = currentValue.capitalized
        } else if elementName == "price"{
            if let num = Double(currentValue) {
                item.price = num
            }
        } else if elementName == "quantity"{
            if let num = Int(currentValue) {
                item.quantity = num
            }
        }
        currentValue = ""
    }
    
    private func parser(parser: XMLParser, parseErrorOccurred parseError: NSError) {
        currentValue = ""
    }
}

extension InfoViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as!CustomTableViewCell
        let number = items[indexPath.row].quantity
        let price = items[indexPath.row].price
        let total = items[indexPath.row].total
        
        cell.textLabel?.text = items[indexPath.row].name.capitalized
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        if let formattedAmount = formatter.string(from: total as NSNumber) {
            cell.detailTextLabel?.text = formattedAmount.replacingOccurrences(of: "UAH", with: "₴")
        }
        if number > 1{
            if let formattedAmount = formatter.string(from: price as NSNumber){
                cell.priceTagLabel.text = formattedAmount.replacingOccurrences(of: "UAH", with: "₴") + " x\(number)"
            }
        }
        totalAmount += total
        cell.backgroundColor = Colors.settingsMainTint
        cell.textLabel?.textColor = Colors.settingsText
        cell.detailTextLabel?.textColor = Colors.settingsText
        cell.priceTagLabel.textColor = Colors.settingsAltText
        return cell
    }

}

class InfoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    
    // supporting variables
    
    var totalAmount: Double = 0 {
        didSet{
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            if let formattedAmount = formatter.string(from: totalAmount as NSNumber) {
                totalLabel.text = "\(formattedAmount)"
            }
        }
    }
    var xmlIndicator = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
    var jsonRequestIndicator = "order_id.json"
    
    var items: [Item] = []
    var item = Item()
    var currentValue: String = ""
    var qrMetadata: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorSetup()
        parseQRData()
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    func parseQRData(){
        if qrMetadata == ""{
            bottomBar.isHidden = true
        } else {
            if qrMetadata.contains(jsonRequestIndicator){
                sendRequest()
            } else {
                if let qrData = qrMetadata.data(using: .utf8, allowLossyConversion: false){
                    if qrMetadata.contains(xmlIndicator){
                        parseXML()
                    } else {
                        parseJSON(from: qrData)
                    }
                }
            }
        }
    }
    
    func parseJSON(from data: Data){
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]{
                for (_, info) in json{
                    if let itemData = info as? [String: Any]{
                        let tempItem = Item()
                        tempItem.name = itemData["name"] as! String
                        tempItem.price = itemData["price"] as! Double
                        tempItem.quantity = itemData["quantity"] as! Int
                        self.items.append(tempItem)
                        tableView.isHidden = false
                    }
                }
            }
        } catch {
            print("Oops")
        }
    }
    
    func parseXML(){
        let startIndex = qrMetadata.range(of: xmlIndicator, options: .literal)?.upperBound
        var correctXML = qrMetadata
        let openTag = Array("<document>".characters)
        let closeTag = Array("</document>".characters)
        correctXML.insert(contentsOf: openTag, at: startIndex!)
        correctXML.insert(contentsOf: closeTag, at: correctXML.endIndex)
        if let data = correctXML.data(using: .utf8, allowLossyConversion: false){
//        let task = URLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
//            if error != nil {
//                println(error)
//                return
//            }
//            
            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
                for item in items{
                    print(item.name)
                }
            } else {
                print(parser.parserError?.localizedDescription ?? "Something went wrong")
            }
        }
        //task.resume()
    }

    func sendRequest(){
        let requestURL: URL = URL(string:  qrMetadata)!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        spinner.startAnimating()
        let task = session.dataTask(with: urlRequest) {(data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                self.parseJSON(from: data!)
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                }
            } else  {
                print("Failed")
            }
        }
        task.resume()
    }
    
    func colorSetup(){
        self.tableView.backgroundColor = Colors.mainBackground
        self.view.backgroundColor = Colors.mainBackground
        bottomBar.backgroundColor = Colors.settingsMainTint
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Scan", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = Colors.deleteColor;
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
}
