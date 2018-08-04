//
//  ViewController.swift
//  tttAITesting
//
//  Created by Johnny on 12/16/17.
//  Copyright © 2017 Johnny. All rights reserved.
//

import GoogleMobileAds
import AVFoundation

import UIKit

class ViewController: UIViewController {
	var isGameInQuantumMode = false
	var onePlayer = true
	var myTurn = false
	let touchFeedBack = UIImpactFeedbackGenerator(style: .heavy)

	@IBOutlet weak var result: UILabel!
	@IBOutlet weak var Button1: UIButton!
	@IBOutlet weak var Button2: UIButton!
	@IBOutlet weak var Button3: UIButton!
	@IBOutlet weak var Button4: UIButton!
	@IBOutlet weak var Button5: UIButton!
	@IBOutlet weak var Button6: UIButton!
	@IBOutlet weak var Button7: UIButton!
	@IBOutlet weak var Button8: UIButton!
	@IBOutlet weak var Button9: UIButton!
	@IBOutlet var buttonarray: [UIButton]!
	@IBAction func clear(_ sender: UIButton) {
		clearBroad()
	}

	@IBOutlet weak var playerState: UIButton!
	@IBAction func player(_ sender: UIButton) {
		clearBroad()
		if(onePlayer){
			onePlayer = false
			sender.setTitle("2Player", for: .normal)
		}else{
			onePlayer = true
			sender.setTitle("1Player", for: .normal)
			isGameInQuantumMode = false
			qState.setTitle("Vanish : OFF", for: .normal)

		}
	}

	@IBOutlet weak var qState: UIButton!
	@IBAction func qButton(_ sender: UIButton) {
		clearBroad()
		qModeFunc(sender)
	}



	func qModeFunc(_ theButton: UIButton){
		switch isGameInQuantumMode {
		case true:
			result.text = " Not In Vanish"
			isGameInQuantumMode = false
			theButton.setTitle("Vanish : OFF", for: .normal)
		case false:
			isGameInQuantumMode = true
			result.text = "In Vanish"
			theButton.setTitle("Vanish : ON", for: .normal)
			onePlayer = false
			playerState.setTitle("2Player", for: .normal)
		}
	}
	var bestButton : UIButton?
	var positionArray = [0,0,0,
						 0,0,0,
						 0,0,0]
	lazy var matchingDic: [UIButton:Int] = [Button1:0 , Button2:1, Button3:2,
											Button4:3, Button5:4, Button6:5,
											Button7:6, Button8:7, Button9:8]
	lazy var revMatchingDic: [Int:UIButton] = [	0 :Button1, 1:Button2, 2:Button3,
												   3 :Button4, 4:Button5, 5:Button6,
												   6 :Button7, 7:Button8, 8:Button9]

	var qModeButtonArray : [UIButton] = []

	var qModeCounter = 0


	@IBAction func gameButton(_ sender: UIButton){
		touchFeedBack.impactOccurred()
		if(isGameFinshed() == false){
			switch isGameInQuantumMode{
			case false:
				if(onePlayer){
					if(positionArray[matchingDic[sender]!] == 0){
						sender.setTitle("X", for: .normal)
						sender.setTitleColor(.black, for: .normal)
						self.positionArray[self.matchingDic[sender]!] = -1
						if(noMoveleft() == false){
							var temp : Int?
							var bestValue = -2

							DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {

								for i in 0...8{
									if (self.positionArray[i] == 0){
										self.positionArray[i] = 1
										let newValue = self.minimax2(false)
										if(newValue > bestValue){
											bestValue = newValue
											temp = i

										}
										self.positionArray[i] = 0
									}
								}
// use array to repersent 1 to 9
								self.positionArray[temp!] = 1
								self.bestButton = self.revMatchingDic[temp!]
								self.bestButton?.setTitle("O", for: .normal)
								self.bestButton?.setTitleColor(.blue, for: .normal)

							}

						}
					}
				}else{
					if(myTurn){
						if(positionArray[matchingDic[sender]!] == 0){
							sender.setTitle("X", for: .normal)
							sender.setTitleColor(.black, for: .normal)
							positionArray[matchingDic[sender]!] = -1
							myTurn = false

						}
					}else{
						if(positionArray[matchingDic[sender]!] == 0){
							sender.setTitle("O", for: .normal)
							sender.setTitleColor(.blue, for: .normal)
							positionArray[matchingDic[sender]!] = 1
							myTurn = true
						}
					}
				}
			case true :
				if(positionArray[matchingDic[sender]!] == 0){
					qModeCounter = qModeCounter + 1
					if(myTurn){
						sender.setTitle("X", for: .normal)
						positionArray[matchingDic[sender]!] = -1
						myTurn = false
						qModeButtonArray.append(sender)
					}else{
						sender.setTitle("O", for: .normal)
						positionArray[matchingDic[sender]!] = 1
						myTurn = true
						qModeButtonArray.append(sender)

					}
					if(qModeCounter >= 6){
						positionArray[matchingDic[qModeButtonArray[0]]!] = 0
						qModeButtonArray[0].setTitle(nil, for: .normal)
						qModeButtonArray.remove(at: 0)
					}
					
				}
			}
		}

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {

			if self.isGameFinshed(){
				if(self.evaluate2() == 1){
					self.result.text = "O Wins"
				}
				if(self.evaluate2() == -1){
					self.result.text = "X Wins"
				}

			}



			if self.isThereAWinner(){
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
				if(self.evaluate2() == 1){
					self.result.text = "O Wins"
				}
				if(self.evaluate2() == -1){
					self.result.text = "X Wins"
				}

			}else if self.noMoveleft(){
					self.result.text = "Draw"
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
			}else if self.ifOnlyOneMovesLeft() && self.onePlayer{
					self.result.text = "Draw"
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
			}

		}

	}

	func clearBroad(){
		for b in buttonarray{
			b.setTitle(nil, for: .normal)
		}
		for i in 0...8{
			positionArray[i] = 0
		}
		result.text = "TicTacToe"
		qModeCounter = 0
		qModeButtonArray.removeAll()
	}
	func isGameFinshed()->Bool{
		if(noMoveleft() || evaluate2() != 0){
			return true
		}
		return false
	}
	func evaluate2() -> Int{
		if(positionArray[0] != 0 && positionArray[0]==positionArray[1] && positionArray[1]==positionArray[2]){return positionArray[0]}
		if(positionArray[3] != 0 && positionArray[3]==positionArray[4] && positionArray[4]==positionArray[5]){return positionArray[3]}
		if(positionArray[6] != 0 && positionArray[6]==positionArray[7] && positionArray[7]==positionArray[8]){return positionArray[6]}
		if(positionArray[0] != 0 && positionArray[0]==positionArray[3] && positionArray[3]==positionArray[6]){return positionArray[0]}
		if(positionArray[1] != 0 && positionArray[1]==positionArray[4] && positionArray[4]==positionArray[7]){return positionArray[1]}
		if(positionArray[2] != 0 && positionArray[2]==positionArray[5] && positionArray[5]==positionArray[8]){return positionArray[2]}
		if(positionArray[0] != 0 && positionArray[0]==positionArray[4] && positionArray[4]==positionArray[8]){return positionArray[0]}
		if(positionArray[2] != 0 && positionArray[2]==positionArray[4] && positionArray[4]==positionArray[6]){return positionArray[2]}
		return 0
	}
	func noMoveleft()-> Bool{
		for i in 0...8{
			if (positionArray[i] == 0){
				return false
			}
		}
		return true
	}
	func isThereAWinner()->Bool{
		if evaluate2() != 0{
			return true
		}else{
			return false
		}
	}

	func minimax2(_ mymove: Bool)-> Int{
		if(evaluate2() != 0){
			return evaluate2()
		}
		if(noMoveleft()){
			return 0
		}
		var pValue : Int?
		if(mymove == true){
			var bestValue = -2
			for i in 0...8 {
				if (positionArray[i] == 0){
					positionArray[i] = 1
					let newValue = minimax2(false)
					if(newValue > bestValue){
						bestValue = newValue
					}
					positionArray[i] = 0
				}
			}
			pValue = bestValue
		}
		if(mymove == false){
			var bestValue = 2
			for i in 0...8 {
				if (positionArray[i] == 0){
					positionArray[i] = -1
					let newValue = minimax2(true)
					if(newValue < bestValue){
						bestValue = newValue
					}
					positionArray[i] = 0
				}
			}
			pValue = bestValue
		}
		return pValue!
	}

	@IBOutlet weak var googleAdView: GADBannerView!


	func ifOnlyOneMovesLeft()->Bool{
		var emptyMovesLeft = 0

		for i in 0...8{
			if positionArray[i] == 0{
				emptyMovesLeft += 1


			}

		}
		if emptyMovesLeft == 1 {

			return true

		}else{
			return false
		}
	}







	override func viewDidLoad() {
		super .viewDidLoad()
		// pub-id 4737842523408736/2365318472





		//print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
		googleAdView.adUnitID = "ca-app-pub-4737842523408736/2365318472"
		googleAdView.rootViewController = self
		let request = GADRequest()
		//ipad	a44f5ea750cb008c2a1c72c435dffffa
		//iphone 94b4da58abc5f4e592c5c5a9a34e3105
		request.testDevices = ["a44f5ea750cb008c2a1c72c435dffffa"]
		googleAdView.load(request)
	}



	func notint(){
		print("noting")
	}

}





























