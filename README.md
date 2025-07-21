# ViewConfigurable 🧩

A Swift macro that brings SwiftUI-style customization to your own reusable view components — without boilerplate.

Inspired by how native SwiftUI views like `Text` and `TextField` separate required data from optional styling, `@ViewConfigurable` makes your custom views easier to use and extend.

---

## ✨ What It Does

With `@ViewConfigurable`, you can:

- Create a `ViewConfiguration` struct inside your view
- Use a single `viewConfig` property to apply all styling
- Automatically generate fluent-style setters like `.font(_:)`, `.backgroundColor(_:)`, `.onScroll(_:)`, etc.
- Keep your initializers small and clean
- Avoid cluttering your `View` with dozens of optional parameters

---

## 📦 Installation

Add the package to your `Package.swift`:

```swift
.package(
  url: "https://github.com/grindrllc/view-configurable",
  from: "0.1.1"
)
```

Then add `"ViewConfigurable"` to your target dependencies:

```swift
.target(
  name: "YourApp",
  dependencies: [
    .product(name: "ViewConfigurable", package: "view-configurable")
  ]
)
```

> Requires **Swift 5.9+** and **Xcode 15+**

---

## 🚀 Getting Started

### 1. Annotate your view with `@ViewConfigurable`

```swift
import SwiftUI
import ViewConfigurable

@ViewConfigurable
public struct GrindrButton: View {
  private let title: String
  private let onAction: () -> Void

  private var viewConfig = ViewConfiguration()

  struct ViewConfiguration {
    var titleColor: Color = .black
    var backgroundColor: Color = .yellow
    var font: Font = .body
  }

  public init(title: String, onAction: @escaping () -> Void) {
    self.title = title
    self.onAction = onAction
  }

  public var body: some View {
    Button(action: onAction) {
      Text(title)
        .font(viewConfig.font)
        .foregroundColor(viewConfig.titleColor)
    }
    .background(viewConfig.backgroundColor)
  }
}
```

### 2. Use it like a native SwiftUI view:

```swift
GrindrButton(title: "Tap Me", onAction: {})
  .titleColor(.blue)
  .backgroundColor(.purple)
  .font(.callout)
```

🎉 You get SwiftUI-style customizability **without** inflating your initializer.

---

## 💡 Why This Matters

As your components grow, constructor-based configuration becomes painful to maintain and use. `@ViewConfigurable` helps you:

- Keep your views clean and maintainable
- Reduce initializer bloat
- Encourage consistent, idiomatic customization

It’s like giving your own views the ergonomics of `Text`, `TextField`, or `Button`.

---

## 🧪 Diagnostics

If your view is missing a `ViewConfiguration` struct or `viewConfig` property, the macro will emit a warning with fix-it suggestions.

---

## 🔐 License

MIT License © 2025 Grindr LLC.  
See [LICENSE](LICENSE) for details.

---

## 🙌 Credits

Built with 💛 by the iOS team at [Grindr](https://grindr.com)

---

## 📬 Feedback or Contributions?

Feel free to open an issue or submit a PR. We’re excited to see how others use `@ViewConfigurable` in their SwiftUI components!
