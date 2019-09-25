//
//  SecondViewController.swift
//  FinalProject
//
//  Created by Student on 12/13/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class SecondViewController: UIViewController, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate {
    @IBOutlet weak var cardPicker: UIPickerView!
    @IBOutlet weak var cardFetcherBtn: UIButton!
    @IBOutlet weak var cardsTable: UITableView!
    
    enum buttonStates {
        case Picker
        case Fetch
    }
    
    var fetchBtnState = buttonStates.Picker // set default state
    var tableData: [OfficialCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.cardPicker.delegate = self
        self.cardPicker.dataSource = self
        
        self.view.bringSubviewToFront(cardPicker)
        cardPicker.isUserInteractionEnabled = true
    }
    
    func fetchData(className: String) {
        let headers: HTTPHeaders = ["X-Mashape-Key": "TSzxux0GdymshSdMijkrTNKD63nHp1s5X0hjsnPx4gMmRHPU64"]
        let url = "https://omgvamp-hearthstone-v1.p.mashape.com/cards/classes/\(className)?collectible=1"
        
        DispatchQueue.main.async {
            Alamofire.request(url, headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        self.tableData.removeAll()
                        let json = JSON(value)
                        for (_, card) in json {
                            let officialCard = OfficialCard(name: card["name"].stringValue,
                                                            flavorText: card["flavor"].stringValue,
                                                            image: card["img"].stringValue)
                            self.tableData.append(officialCard)
                        }
                        self.cardsTable.reloadData()
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    @IBAction func cardFetcherBtnAction(_ sender: Any) {
        switch fetchBtnState {
        case .Picker:
            showPicker()
        case .Fetch:
            fetchCards()
        default:
            break
        }
    }
    
    func fetchCards() {
        fetchBtnState = .Picker
        cardPicker.isHidden = true
        cardFetcherBtn.setTitle("Classes", for: .normal)
        fetchData(className: CardPickerData.classes[cardPicker.selectedRow(inComponent: 0)])
    }
    
    func showPicker() {
        print("picker")
        fetchBtnState = .Fetch
        cardPicker.isHidden = false
        cardFetcherBtn.setTitle("\(CardPickerData.classes[cardPicker.selectedRow(inComponent: 0)]) Cards - GO!", for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CardPickerData.classes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CardPickerData.classes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cardFetcherBtn.setTitle("\(CardPickerData.classes[row] as String) Cards - GO!", for: .normal)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell") as? CardTableCell else {
            return UITableViewCell()
        }
        cell.name.text = tableData[indexPath.row].name
        cell.flavorText.text = tableData[indexPath.row].flavorText
        
        let url = URL(string: tableData[indexPath.row].image)
        cell.cardImage.kf.indicatorType = .activity
        cell.cardImage.kf.setImage(
            with: url,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        return cell
    }
}

