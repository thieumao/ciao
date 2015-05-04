//
//  GameMasterViewController.swift
//  Ciao Game
//
//  Created by Clinton D'Annolfo on 21/02/2015.
//  Copyright (c) 2015 Clinton D'Annolfo. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class GameMasterViewController: UIViewController, LanguageGameModelDelegate {

    //MARK: - Outlets
    @IBOutlet weak var wordLabel: UILabel! /*{
        didSet {
            wordLabel.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:"pan:"))
        }
    }*/
    @IBOutlet var gameButtonCollection: [GameButton]!
    @IBOutlet weak var soundButton: UIBarButtonItem!
    
    //MARK: - Properties
    var game: LanguageGame!
    var managedObjectContext: NSManagedObjectContext? = nil
    var coreDataDelegate: CoreDataDelegate!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //MARK: - Initialisers    
    deinit {
        var error: NSErrorPointer = NSErrorPointer()
        if (managedObjectContext?.save(error) == nil) {
            println("Error: \(error.debugDescription)")
        } else {
            println("Managed Object Context save successful on \(self) deinit")
        }
    }
    
    //MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        var error = NSErrorPointer()
        game.fetchData(error)
        game.currentStreak = 0
        setHasSound(game.hasSound)
        setButtonCollectionStyle()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        //
    }
    
    //MARK: - Game methods
    internal func setButtonCollectionStyle () {
        for gameButton in gameButtonCollection {
            gameButton.layer.cornerRadius = CGFloat(2)
            gameButton.titleLabel?.textAlignment = NSTextAlignment.Center
        }
    }
    
    //MARK: - Model Delegate
    func setHasSound(hasSound: Bool) {
        if (hasSound == true) {
            soundButton.title = NSLocalizedString("Sound On", comment: "Button to turn the game sound on")
        } else {
            soundButton.title = NSLocalizedString("Sound Off", comment: "Button to turn the game sound off")
        }
    }
    
    //MARK: - Target Action
    @IBAction func tapWordLabel(sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        sayWord(label.text!, localWord: nil)
    }
    
    @IBAction func clickSoundButton(sender: UIBarButtonItem) {
        game.hasSound = !game.hasSound
    }
    
    //MARK: - Text to speech
    internal func sayWord (foreignWord: String, localWord: String?) {
        if game.hasSound {
            let dataPlistPath: String = NSBundle.mainBundle().pathForResource("IETFLanguageCode", ofType:"strings")!
            let IETFCodeDictionary = NSDictionary(contentsOfFile: dataPlistPath)!
            let synthesizer = AVSpeechSynthesizer()
            if ((localWord) != nil) {
                var utteranceAnswer = AVSpeechUtterance(string: localWord!)
                //                var utteranceAnswer = AVSpeechUtterance(string: foreignWord)
                utteranceAnswer.rate = self.game.speakingSpeed
                println("Speaking local \(localWord!)")
                synthesizer.speakUtterance(utteranceAnswer)
            }
            //utteranceAnswer.voice = AVSpeechSynthesisVoice(language: "en-AU")
            var utteranceWord = AVSpeechUtterance(string: foreignWord)
            if let languageCode = IETFCodeDictionary.valueForKey(userDefaults.stringForKey("language")!) as? String {
                utteranceWord.voice = AVSpeechSynthesisVoice(language: languageCode)
            }
            utteranceWord.rate = self.game.speakingSpeed
            println("Speaking foreign \(foreignWord)")
            synthesizer.speakUtterance(utteranceWord)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
