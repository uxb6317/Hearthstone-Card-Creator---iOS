//
//  FirstViewController.swift
//  FinalProject
//
//  Created by Student on 12/13/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import PopupDialog
import RealmSwift

class FirstViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var classPickerBtn: UIButton!
    @IBOutlet weak var typePickerBtn: UIButton!
    @IBOutlet weak var rarityPickerBtn: UIButton!
    @IBOutlet weak var selectPickerBtn: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var attack: UILabel!
    @IBOutlet weak var healthDurability: UILabel!
    @IBOutlet weak var cardDesc: UILabel!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    var currentActiveSelectedBtn: UIButton!
    var selectedPickerValue = ""
    var pickerData = [String]()
    var currentPickerType = ""
    
    var card: Card!
    let cardId = "1A61F308-4431-4A1D-AC00-20CC6E425BE7"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        labelInteractions(labels: [cost, cardName, cardDesc, healthDurability, attack]) // listen for taps on all labels
    
        let realm = try! Realm()

        card = realm.object(ofType: Card.self, forPrimaryKey: cardId)
        initRenderCard(card: card)
    }
    
    func initRenderCard(card: Card) {
        cost.text = card.cost
        if card.type == "minion" {
            healthDurability.text = card.health
        } else if card.type == "weapon" {
            healthDurability.text = card.durability
        }
        attack.text = card.attack
        cardName.text = card.name
        cardDesc.text = card.cardDescription
        cardImage.image = UIImage(named: card.image)
        classPickerBtn.setTitle(card.cardClass.capitalizingFirstLetter(), for: .normal)
        typePickerBtn.setTitle(card.type.capitalizingFirstLetter(), for: .normal)
        rarityPickerBtn.setTitle(card.rarity.capitalizingFirstLetter(), for: .normal)
    }
    
    // this function allows me to set the same UITapGestureRecognizer for multiple views
    func setTapGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FirstViewController.updateValue))
        tapRecognizer.numberOfTapsRequired = 1
        return tapRecognizer
    }
    
    // connect the labels to a UITapGestureRecognizer
    func labelInteractions(labels: [UILabel]) {
        for label in labels {
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(setTapGestureRecognizer())
        }
    }
    
    // a dialog for getting input from user to update the card values
    func inputDialog(title: String, message: String, tappedLabel: UILabel, isNumInput: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let realm = try! Realm()

        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            let value = alertController.textFields?[0].text
            try! realm.write {
                switch tappedLabel {
                case self.cost:
                    self.card.cost = value ?? ""
                case self.attack:
                    self.card.attack = value ?? ""
                case self.healthDurability:
                    if self.card.type == "minion" {
                        self.card.health = value ?? ""
                    } else {
                        self.card.durability = value ?? ""
                    }
                case self.cardDesc:
                    self.card.cardDescription = value ?? ""
                case self.cardName:
                    self.card.name = value ?? ""
                default:
                    break
                }
            }
            tappedLabel.text = value // update the value of the label that was tapped with the entered value
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            // show number only pad for labels that only need number inputs
            textField.keyboardType = isNumInput ? UIKeyboardType.decimalPad : UIKeyboardType.default
            textField.placeholder = "Enter Value"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // listen for taps on the labels and update the corresponding UILabel
    @objc func updateValue(sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        switch label {
        case cost:
            inputDialog(title: "Cost", message: "Enter the cost value for this card:", tappedLabel: cost, isNumInput: true)
        case attack:
            inputDialog(title: "Attack", message: "Enter the attack value for this card:", tappedLabel: attack, isNumInput: true)
        case healthDurability:
            inputDialog(title: "Health/Durability", message: "Enter the health or durability value for this card:", tappedLabel: healthDurability, isNumInput: true)
        case cardDesc:
            inputDialog(title: "Description", message: "Enter the description for this card:", tappedLabel: cardDesc, isNumInput: false)
        case cardName:
            inputDialog(title: "Name", message: "Enter the name for this card:", tappedLabel: cardName, isNumInput: false)
        default:
            print("wat")
        }
    }

    @IBAction func typeClick(_ sender: Any) {
        currentPickerType = "Type"
        updatePickerBtns(btn: sender as! UIButton)
        showPicker(data: CardPickerData.types)
    }
    @IBAction func classClick(_ sender: Any) {
        currentPickerType = "Class"
        updatePickerBtns(btn: sender as! UIButton)
        
        var dataForPicker = CardPickerData.classes
        if (card.type == "spell") {
            // no image resource for legendary spells
            dataForPicker = dataForPicker.filter{$0 != "Neutral"}
        }
        
        showPicker(data: dataForPicker)
    }
    @IBAction func rarityClick(_ sender: Any) {
        currentPickerType = "Rarity"
        updatePickerBtns(btn: sender as! UIButton)
        
        var dataForPicker = CardPickerData.rarities
        if (card.cardClass == "neutral" && card.type == "minion") {
            // I don't have the image resource for a common neutral minion, so don't show on option for it in the picker
            dataForPicker = dataForPicker.filter{$0 != "Common"}
        }
        if (card.type == "spell") {
            // no image resource for legendary spells
            dataForPicker = dataForPicker.filter{$0 != "Legendary"}
        }
        showPicker(data: dataForPicker)
    }
    @IBAction func selectPicker(_ sender: Any) {
        resetPickerBtns(buttons: [classPickerBtn, rarityPickerBtn, typePickerBtn])
        picker.isHidden = true
        selectPickerBtn.isHidden = true
        
        // enable class picker button incase it's disabled
        changeBtnState(btn: classPickerBtn, state: true)
        
        let pickerSelection = pickerData[picker.selectedRow(inComponent: 0)] // item that was selected from picker
        
        let realm = try! Realm()
        
        try! realm.write {
            switch currentPickerType {
            case "Rarity":
                card.rarity = pickerSelection.lowercased()
                
                if (card.type == "weapon") {
                    changeBtnState(btn: classPickerBtn, state: false)
                }
            case "Class":
                card.cardClass = pickerSelection.lowercased()
            case "Type":
                switch pickerSelection.lowercased() {
                case "hero":
                    if (pickerSelection.lowercased() == "hero") {
                        // i don't the image resources for heroes...
                        let alert = UIAlertController(title: "Sorry :(", message: "Heroes aren't supported (yet).", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                        return
                    }
                case "weapon":
                    // weapons don't have class specific images, only neutral weapons
                    // so disable the button to pick classes
                    changeBtnState(btn: classPickerBtn, state: false)
                default:
                    break
                }
                
                card.type = pickerSelection.lowercased()
            default:
                card.image = "neutral_collectable_minion"
            }
            
            if card.type == "weapon" {
                // handle weapon selection
                card.image = "\(card.rarity)_weapon"
            } else {
                card.image = "\(card.cardClass)_\(card.rarity)_\(card.type)"
            }
            
            cardImage.image = UIImage(named: card.image)
        }
        currentActiveSelectedBtn.setTitle(pickerSelection, for: .normal)
    }
    
    func changeBtnState(btn: UIButton, state: Bool) {
        btn.isEnabled = state
        btn.isUserInteractionEnabled = state
        let color = state ? UIColor.black : UIColor.gray
        btn.setTitleColor(color, for: .normal)
    }
    
    func showPicker(data: [String]) {
        pickerData = data
        picker.reloadAllComponents()
        picker.isHidden = false
        selectPickerBtn.isHidden = false
    }
    
    func updatePickerBtns(btn: UIButton) {
        resetPickerBtns(buttons: [classPickerBtn, rarityPickerBtn, typePickerBtn])
        currentActiveSelectedBtn = btn
        btn.backgroundColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0)
        btn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func resetPickerBtns(buttons: [UIButton]) {
        for button in buttons {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0), for: .normal)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

// from - https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
