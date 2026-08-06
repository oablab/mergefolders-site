// Renders the 1200x630 Open Graph cards for the Mergic custom-tokens note.
// Usage: swift scripts/render_og_custom_tokens.swift <lang: en|zh|ja|ko> <output.png>
import AppKit

struct Copy {
    let title1: String
    let title2: String
    let sub1: String
    let sub2: String
    let titleSize: CGFloat
    let subSize: CGFloat
}

let copies: [String: Copy] = [
    "en": Copy(
        title1: "Your rule is just",
        title2: "a function.",
        sub1: "User-defined tokens in JavaScript — sandboxed,",
        sub2: "with the whole EXIF object in hand.",
        titleSize: 64, subSize: 29),
    "zh": Copy(
        title1: "你的規則，",
        title2: "就是一個函數。",
        sub1: "JavaScript 自訂代碼——沙盒執行，",
        sub2: "整包 EXIF 物件直接給你。",
        titleSize: 62, subSize: 29),
    "ja": Copy(
        title1: "あなたのルールは、",
        title2: "ただの関数。",
        sub1: "JavaScript のカスタムトークン——サンドボックスで、",
        sub2: "EXIF オブジェクトをまるごと手渡し。",
        titleSize: 58, subSize: 26),
    "ko": Copy(
        title1: "당신의 규칙은",
        title2: "그저 함수 하나.",
        sub1: "JavaScript 커스텀 토큰 — 샌드박스에서,",
        sub2: "EXIF 객체를 통째로.",
        titleSize: 62, subSize: 29),
]

let lang = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "en"
let out = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "og-\(lang).png"
guard let copy = copies[lang] else {
    fputs("unknown lang \(lang)\n", stderr)
    exit(1)
}

let W = 1200, H = 630

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let rect = NSRect(x: 0, y: 0, width: W, height: H)

let bgDeep = NSColor(srgbRed: 0.086, green: 0.071, blue: 0.122, alpha: 1)
let bgLift = NSColor(srgbRed: 0.165, green: 0.133, blue: 0.243, alpha: 1)
let ink    = NSColor(srgbRed: 0.925, green: 0.914, blue: 0.961, alpha: 1)
let muted  = NSColor(srgbRed: 0.639, green: 0.612, blue: 0.733, alpha: 1)
let accent = NSColor(srgbRed: 0.608, green: 0.541, blue: 0.839, alpha: 1)

NSGradient(starting: bgLift, ending: bgDeep)!.draw(in: rect, angle: -55)

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

// (f)=> glyph inside the watermark card — this note is about functions
draw("(f)=>", x: 880, y: 210,
     font: NSFont.monospacedSystemFont(ofSize: 130, weight: .bold),
     color: accent.withAlphaComponent(0.13))

let iconPath = "/Users/pahud/repo/mergic/assets/AppIcon.icns"
if let icon = NSImage(contentsOfFile: iconPath) {
    icon.draw(in: NSRect(x: 84, y: H - 64 - 72, width: 72, height: 72),
              from: .zero, operation: .sourceOver, fraction: 1.0)
}
draw("Mergic", x: 172, y: CGFloat(H) - 64 - 58,
     font: NSFont.systemFont(ofSize: 40, weight: .bold), color: ink)

let titleFont = NSFont.systemFont(ofSize: copy.titleSize, weight: .bold)
draw(copy.title1, x: 84, y: 336, font: titleFont, color: ink, kern: -0.5)
draw(copy.title2, x: 84, y: 336 - copy.titleSize - 16, font: titleFont, color: ink, kern: -0.5)

let subFont = NSFont.systemFont(ofSize: copy.subSize, weight: .regular)
draw(copy.sub1, x: 86, y: 178, font: subFont, color: muted)
draw(copy.sub2, x: 86, y: 178 - copy.subSize - 13, font: subFont, color: muted)

draw("mergic.foldic.app/notes", x: 86, y: 68,
     font: NSFont.monospacedSystemFont(ofSize: 27, weight: .medium), color: accent)

NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out) (\(W)x\(H)) [\(lang)]")
