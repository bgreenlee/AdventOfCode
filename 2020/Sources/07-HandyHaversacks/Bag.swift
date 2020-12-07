import Foundation

struct Bag: Hashable {
    let color: String
    var parents: Set<Bag> = []
    var children: Set<Bag> = []
    var ancestors: Set<Bag> {
        var anc = parents
        for parent in parents {
            anc.formUnion(parent.ancestors)
        }
        return anc
    }

    init(_ color: String) {
        self.color = color
    }

    static func == (lhs: Bag, rhs: Bag) -> Bool {
        return lhs.color ==  rhs.color
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(color)
    }
}
