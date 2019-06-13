//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


struct NoopColors: Decodable {
	var colors: [[String: String]]
}

class MyViewController : UIViewController {


	var colors: NoopColors?

	override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view

		getColors { (colors) in
			print("got the colors!")
			print(colors)
		}



    }

	func getColors(completionBlock: @escaping (NoopColors) -> Void) {
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
				let colors = try decoder.decode(NoopColors.self, from: data)
				completionBlock(colors)

			} catch {
				print("Unable to decode JSON")
			}

			}.resume()
	}
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
