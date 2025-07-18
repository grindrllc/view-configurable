import SwiftUI
import ViewConfigurable

@ViewConfigurable
struct TitleDescriptionView: View {
    private var viewConfig = ViewConfiguration()
    
    private struct ViewConfiguration {
        var titleColor: Color = .primary
        var descriptionColor: Color = .secondary
    }
    
    let title: String
    let description: String

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    public var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .foregroundColor(viewConfig.titleColor)
            Text(description)
                .foregroundColor(viewConfig.descriptionColor)
        }
    }
}
