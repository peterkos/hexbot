//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport



struct Noop: Decodable {
	var colors: [NoopColor]
}

struct NoopColor: Decodable {
	var value: String
	var coordinates: Coordiante?

}

struct Coordiante: Decodable {
	var x: Int
	var y: Int
}

class MyViewController : UIViewController {


	var noop: Noop?

	override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view

		getNoop { (noop) in
			print("got the noop!")
			self.noop = noop

			guard let noop = noop else {
				return
			}

			// Let's do some things!

			// Grab the color
			let firstColor = UIColor(hexString: noop.colors.first!.value)

			DispatchQueue.main.async() {
				// Set the text color, on the main thread of course
				label.backgroundColor = firstColor
			}
		}

    }

	func getNoop(completionBlock: @escaping (Noop?) -> Void) {
		let noopsURL = URL(string: "https://api.noopschallenge.com/hexbot")!
		let task = URLSession.shared.dataTask(with: noopsURL) { (data, response, error) in
			if let error = error {
				print("ERROR: \(error)")
				return
			}

			guard let data = data else {
				let newResponse = response as? HTTPURLResponse
				print("Unable to get data.")
				print("Response code: \(newResponse?.statusCode ?? 404)")
				return
			}

			// Decode the json
			let decoder = JSONDecoder()

			do {
				let noop = try decoder.decode(Noop.self, from: data)
				completionBlock(noop)

			} catch {
				print("Unable to decode JSON")
			}

			}
		task.resume()
	}
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()



// UIKIt doesn't have an easy way to turn a hex string into a UIColor (!?!?!)
// So, the Internet comes to the rescue!
// src: https://gist.github.com/benhurott/d0ec9b3eac25b6325db32b8669196140 (modified slightly)
extension UIColor {
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
		let a, r, g, b: UInt32
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
}
