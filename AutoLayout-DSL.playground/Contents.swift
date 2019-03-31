//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

protocol LayoutAnchor {
    func constraint(equalTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    
    func constraint(greaterThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    
    func constraint(lessThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
}

extension NSLayoutAnchor: LayoutAnchor { }

struct LayoutProperty<Anchor: LayoutAnchor> {
    fileprivate let anchor: Anchor
}

extension LayoutProperty {
    func equal(to otherAnchor: Anchor, offset constant: CGFloat = 0){
        anchor.constraint(equalTo: otherAnchor, constant: constant).isActive = true
    }
    
    func greaterThanOrEqual(to otherAnchor: Anchor, offset constant: CGFloat = 0) {
        anchor.constraint(greaterThanOrEqualTo: otherAnchor, constant: constant).isActive = true
    }
    
    func lessThanOrEqual(to otherAnchor: Anchor, offset constant: CGFloat = 0) {
        anchor.constraint(lessThanOrEqualTo: otherAnchor, constant: constant).isActive = true
    }
}

class LayoutProxy {
    lazy var leading = property(with: view.leadingAnchor)
    lazy var trailing = property(with: view.trailingAnchor)
    lazy var top = property(with: view.topAnchor)
    lazy var bottom = property(with: view.bottomAnchor)
    lazy var width = property(with: view.widthAnchor)
    lazy var height = property(with: view.heightAnchor)
    
    private let view: UIView
    
    fileprivate init(view: UIView) {
        self.view = view
    }
    
    private func property<A:LayoutAnchor>(with anchor: A) -> LayoutProperty<A> {
        return LayoutProperty(anchor: anchor)
    }
}

extension UIView {
    func layout(using closure:(LayoutProxy) -> Void) {
        translatesAutoresizingMaskIntoConstraints = false
        closure(LayoutProxy(view: self))
    }
}

func +<A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, rhs)
}
func -<A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, -rhs)
}
func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A,CGFloat)) {
    lhs.equal(to: rhs.0, offset: rhs.1)
}
func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
    lhs.equal(to: rhs)
}
func >=<A: LayoutAnchor>(lhs: LayoutProperty<A>,
                         rhs: (A, CGFloat)) {
    lhs.greaterThanOrEqual(to: rhs.0, offset: rhs.1)
}

func >=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
    lhs.greaterThanOrEqual(to: rhs)
}

func <=<A: LayoutAnchor>(lhs: LayoutProperty<A>,
                         rhs: (A, CGFloat)) {
    lhs.lessThanOrEqual(to: rhs.0, offset: rhs.1)
}

func <=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
    lhs.lessThanOrEqual(to: rhs)
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = .zero
        label.text = "Hello World!"
        label.textColor = .black
        view.addSubview(label)
        
        label.layout {
            $0.top == view.topAnchor + 20
            $0.leading == view.leadingAnchor
            $0.height == view.widthAnchor
        }
        
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
