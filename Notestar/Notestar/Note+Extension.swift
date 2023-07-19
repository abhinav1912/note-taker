//

import Foundation

extension Note {
    func isNull() -> Bool {
        return (
            title == nil &&
            summary == nil &&
            body == nil
        )
    }
}
