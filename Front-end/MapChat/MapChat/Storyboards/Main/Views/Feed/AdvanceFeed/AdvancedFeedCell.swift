//
//  AdvancedFeedCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/26/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

struct Emoji {
    var emojiIcon:String
    var emojiName:String
}

class AdvancedFeedCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var reactButton: DesignableButton!
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var viewHolder: UIView!
    
    var emojis:[Emoji]!
    
    var emojiView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("inside cell")
        
        emojis = [Emoji(emojiIcon: "🔥", emojiName: "Lit"),
                  Emoji(emojiIcon: "😆", emojiName: "Sweet"),
                  Emoji(emojiIcon: "😀", emojiName: "Cool"),
                  Emoji(emojiIcon: "😂", emojiName: "lol"),
                  Emoji(emojiIcon: "😕", emojiName: "Huh"),
                  Emoji(emojiIcon: "😑", emojiName: "Wtf")]
        
        // create collection view and hide
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        emojiView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.viewHolder.frame.width, height: self.viewHolder.frame.height), collectionViewLayout: flowLayout)

        emojiView.delegate = self
        emojiView.dataSource = self

        emojiView.register(UINib(nibName: "EmojiPickerNib", bundle: nil), forCellWithReuseIdentifier: "EmojiCollectionCellObject")
        emojiView.showsVerticalScrollIndicator = false
        emojiView.showsHorizontalScrollIndicator = false
        emojiView.backgroundColor = UIColor.clear

        viewHolder.addSubview(emojiView)
        
        if DarkModeBool.darkmodeflag == true
        {
            backgroundColor = .black
            displayName.textColor = .white
            username.textColor = .white
            reactButton.backgroundColor = .black
            message.textColor = .white
            viewHolder.backgroundColor = .black
        }
        else if DarkModeBool.darkmodeflag == false
        {
            backgroundColor = .white
            displayName.textColor = .black
            username.textColor = .black
            reactButton.backgroundColor = .white
            message.textColor = .black
            viewHolder.backgroundColor = .white
        }

//        emojiView.isHidden = true
//        reactButton.isHidden = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        emojiView.isHidden = true
        reactButton.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func dropDown(_ sender: Any) {
        
    }
    
    @IBAction func react(_ sender: Any) {
        reactButton.isHidden = true
        emojiView.isHidden = false
//
//        self.emojiView.alpha = 0
//        UIView.animate(withDuration: 1, animations: {
//            self.emojiView.alpha = 1
//        })
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
        
        // update UI
        // let cell = emojiView.cellForItem(at: indexPath)
        reactButton.isHidden = false
        emojiView.isHidden = true
        
        print("showing thing")
        
        let selectedEmoji = emojis[indexPath.row]
        
        reactButton.setTitle("\(selectedEmoji.emojiIcon) \(selectedEmoji.emojiName) ", for: .normal)
        
        //sleep(10)
        print("calling wait")
        // ------ wait and show again
        //waitAndShowAgain()
    }
    
    func waitAndShowAgain() {
        print("waiting")
        sleep(3)
        print("do it")
        reactButton.isHidden = true
        emojiView.isHidden = false
    }

    func collectionView(_ collfectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // let cell:PlaceCollectionCell = placesView.dequeueReusableCell(withReuseIdentifier: "PlaceCellObject", for: indexPath) as! PlaceCollectionCell
        let cell:EmojiCollectionCell = emojiView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionCellObject", for: indexPath) as! EmojiCollectionCell
        
        cell.emojiIcon.text = emojis[indexPath.row].emojiIcon
        // cell.emojiIcon.text = "😀"

        return cell
    }
}
