// Renders the 1200x630 Open Graph cards for the Mergic path-modifier note.
// Usage: swift scripts/render_og.swift <lang: en|zh|ja|ko> <output.png>
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
        title1: "A modifier between",
        title2: "source and destination.",
        sub1: "Copying is a pipeline. Capture date, camera brand,",
        sub2: "per-token fallbacks — same conflict guarantees.",
        titleSize: 64, subSize: 29),
    "zh": Copy(
        title1: "在來源與目的地之間，",
        title2: "放一個修飾器。",
        sub1: "複製是一條管線。拍攝日期、相機品牌、",
        sub2: "逐代碼 fallback——衝突保證一個字都沒改。",
        titleSize: 62, subSize: 29),
    "ja": Copy(
        title1: "コピー元とコピー先の",
        title2: "あいだに、モディファイアを。",
        sub1: "コピーはパイプライン。撮影日、カメラブランド、",
        sub2: "トークンごとのフォールバック——衝突の保証はそのまま。",
        titleSize: 56, subSize: 27),
    "ko": Copy(
        title1: "원본과 대상 사이에,",
        title2: "모디파이어를.",
        sub1: "복사는 파이프라인. 촬영 날짜, 카메라 브랜드,",
        sub2: "토큰별 폴백 — 충돌 보장은 그대로.",
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
let titleFont = NSFont.systemFont(ofSize: copy.titleSize, weight: .bold)
draw(copy.title1, x: 84, y: 336, font: titleFont, color: ink, kern: -0.5)
draw(copy.title2, x: 84, y: 336 - copy.titleSize - 16, font: titleFont, color: ink, kern: -0.5)

// Subtitle
let subFont = NSFont.systemFont(ofSize: copy.subSize, weight: .regular)
draw(copy.sub1, x: 86, y: 178, font: subFont, color: muted)
draw(copy.sub2, x: 86, y: 178 - copy.subSize - 13, font: subFont, color: muted)

// URL
draw("mergic.foldic.app/notes", x: 86, y: 68,
     font: NSFont.monospacedSystemFont(ofSize: 27, weight: .medium), color: accent)

NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out) (\(W)x\(H)) [\(lang)]")
