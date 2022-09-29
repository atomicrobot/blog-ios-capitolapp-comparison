import UIKit
import SwiftUI
import MapKit

class ViewController: UIViewController {

     override func viewDidLoad() {
        let childView = UIHostingController(rootView: SwiftUIView())
         addChild(childView)
         childView.view.frame = self.view.frame
         view.addSubview(childView.view)
         childView.didMove(toParent: self)
    }
}


