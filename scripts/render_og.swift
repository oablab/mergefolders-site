// Renders the 1200x630 Open Graph card for a Mergic dev note.
// Usage: swift scripts/render_og.swift <output.png>
import AppKit

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "og.png"

let W = 1200, H = 630

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let rect = NSRect(x: 0, y: 0, width: W, height: H)

// Palette (site dark theme)
let bgDeep = NSColor(srgbRed: 0.086, green: 0.071, blue: 0.122, alpha: 1)   // #16121F
let bgLift = NSColor(srgbRed: 0.165, green: 0.133, blue: 0.243, alpha: 1)   // lifted violet
let ink    = NSColor(srgbRed: 0.925, green: 0.914, blue: 0.961, alpha: 1)   // #ECE9F5
let muted  = NSColor(srgbRed: 0.639, green: 0.612, blue: 0.733, alpha: 1)   // #A39CBB
let accent = NSColor(srgbRed: 0.608, green: 0.541, blue: 0.839, alpha: 1)   // #9B8AD6

// Background gradient
NSGradient(starting: bgLift, ending: bgDeep)!.draw(in: rect, angle: -55)

// Watermark: big faint rounded card off the right edge with ${…}
let card = NSBezierPath(
    roundedRect: NSRect(x: 830, y: 40, width: 500, height: 470),
    xRadius: 64, yRadius: 64)
accent.withAlphaComponent(0.07).setFill()
card.fill()
accent.withAlphaComponent(0.12).setStroke()
card.lineWidth = 2
card.stroke()

func draw(_ text: String, x: CGFloat, y: CGFloat, font: NSFont, color: NSColor, kern: CGFloat = 0) {
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .kern: kern]
    NSAttributedString(string: text, attributes: attrs).draw(at: NSPoint(x: x, y: y))
}

// ${…} glyph inside the watermark card
draw("${…}", x: 905, y: 200,
     font: NSFont.monospacedSystemFont(ofSize: 150, weight: .bold),
     color: accent.withAlphaComponent(0.13))

// Brand: app icon + name, top-left
let iconPath = "/Users/pahud/repo/mergic/assets/AppIcon.icns"
if let icon = NSImage(contentsOfFile: iconPath) {
    icon.draw(in: NSRect(x: 84, y: H - 64 - 72, width: 72, height: 72),
              from: .zero, operation: .sourceOver, fraction: 1.0)
}
draw("Mergic", x: 172, y: CGFloat(H) - 64 - 58,
     font: NSFont.systemFont(ofSize: 40, weight: .bold), color: ink)

// Title
let titleFont = NSFont.systemFont(ofSize: 64, weight: .bold)
draw("A modifier between",        x: 84, y: 336, font: titleFont, color: ink, kern: -0.5)
draw("source and destination.",   x: 84, y: 256, font: titleFont, color: ink, kern: -0.5)

// Subtitle
let subFont = NSFont.systemFont(ofSize: 29, weight: .regular)
draw("Copying is a pipeline. Capture date, camera brand,", x: 86, y: 178, font: subFont, color: muted)
draw("per-token fallbacks — same conflict guarantees.",    x: 86, y: 136, font: subFont, color: muted)

// URL
draw("mergic.foldic.app/notes", x: 86, y: 68,
     font: NSFont.monospacedSystemFont(ofSize: 27, weight: .medium), color: accent)

NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out) (\(W)x\(H))")
