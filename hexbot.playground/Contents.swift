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
			let firstColor = noop.colors.first!

			// @TODO: convert to UIColor... somehow. Bit shifting?
			print(firstColor.value)
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

			}.resume()
	}
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
