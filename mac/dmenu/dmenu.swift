// dmenu for macOS, after dmenu on Linux (desktop/linux/dwm/dmenu): reads items from stdin, shows a bar
// over the top of the screen (over SketchyBar, as dmenu covers the dwm bar), prints the selection.
//
// usage: dmenu [-b] [-i] [-l lines] [-p prompt] [-fn font] [-nb color] [-nf color] [-sb color] [-sf color]
//   -m is accepted and ignored (dmenu shows on the screen under the mouse). Colours: #rrggbb.
//   Defaults: the bar colours of the desktop theme (~/.config/theme/sketchybar.sh, written by `theme`),
//   font PxPlus IBM VGA 8x16 with Cubic 11 for Chinese.
// keys: type to filter; Tab complete; Left/Right, Up/Down, Ctrl-n/p move; Return select (the typed text
//   when nothing matches); Shift-Return the typed text; Esc or Ctrl-c cancel (exit 1); Ctrl-u clear;
//   Ctrl-w delete word; Cmd-v paste.
// build: swiftc -O dmenu.swift -o ~/.local/bin/dmenu   (bootstrap.sh builds)
import Cocoa

// ---- options -------------------------------------------------------------------------------------

var prompt = "", insensitive = false, bottom = false, lines = 0
var fontName = "PxPlus IBM VGA 8x16"
let fontSize: CGFloat = 16, rowHeight: CGFloat = 32          // the SketchyBar height
var nb = "#222222", nf = "#bbbbbb", sb = "#005577", sf = "#eeeeee"   // dmenu's own defaults

// theme colours: BAR_BG=0xffRRGGBB lines
if let theme = try? String(contentsOfFile: NSHomeDirectory() + "/.config/theme/sketchybar.sh", encoding: .utf8) {
    for line in theme.split(separator: "\n") {
        let kv = line.split(separator: "=", maxSplits: 1).map(String.init)
        guard kv.count == 2 else { continue }
        switch kv[0] {
        case "BAR_BG": nb = kv[1]
        case "BAR_FG": nf = kv[1]
        case "SEL_BG": sb = kv[1]
        case "SEL_FG": sf = kv[1]
        default: break
        }
    }
}

var args = CommandLine.arguments.dropFirst().makeIterator()
while let a = args.next() {
    switch a {
    case "-b": bottom = true
    case "-i": insensitive = true
    case "-l": lines = Int(args.next() ?? "") ?? 0
    case "-p": prompt = args.next() ?? ""
    case "-fn": fontName = String((args.next() ?? fontName).split(separator: ":").first ?? "")  // "Family:pixelsize=.."
    case "-nb": nb = args.next() ?? nb
    case "-nf": nf = args.next() ?? nf
    case "-sb": sb = args.next() ?? sb
    case "-sf": sf = args.next() ?? sf
    case "-m": _ = args.next()
    default: FileHandle.standardError.write("dmenu: unknown option \(a)\n".data(using: .utf8)!); exit(1)
    }
}

func color(_ s: String) -> NSColor {
    var h = s.lowercased()
    if h.hasPrefix("#") { h.removeFirst() } else if h.hasPrefix("0x") { h = String(h.dropFirst(4)) }  // 0xAARRGGBB
    let v = UInt32(h, radix: 16) ?? 0
    return NSColor(srgbRed: CGFloat(v >> 16 & 0xff) / 255, green: CGFloat(v >> 8 & 0xff) / 255,
                   blue: CGFloat(v & 0xff) / 255, alpha: 1)
}
let (normBg, normFg, selBg, selFg) = (color(nb), color(nf), color(sb), color(sf))

let font: NSFont = {
    let base = NSFont(descriptor: NSFontDescriptor(fontAttributes: [.family: fontName]), size: fontSize)
        ?? .monospacedSystemFont(ofSize: fontSize, weight: .regular)
    let cjk = NSFontDescriptor(fontAttributes: [.family: "Cubic 11"])
    return NSFont(descriptor: base.fontDescriptor.addingAttributes([.cascadeList: [cjk]]), size: fontSize) ?? base
}()

// ---- items ---------------------------------------------------------------------------------------

func readStdin() -> [String] {
    guard isatty(0) == 0 else { return [] }                  // no input piped in, e.g. a password prompt
    var data = Data(), buf = [UInt8](repeating: 0, count: 65536)
    while true {
        let n = read(0, &buf, buf.count)                     // -1 when stdin is closed (`<&-`)
        if n <= 0 { break }
        data.append(buf, count: n)
    }
    return String(decoding: data, as: UTF8.self).split(separator: "\n").map(String.init)
}
let items = readStdin()

// dmenu's match(): every space-separated token must occur; exact matches first, then prefixes, then the rest
func filter(_ text: String) -> [String] {
    if text.isEmpty { return items }
    let opt: String.CompareOptions = insensitive ? .caseInsensitive : []
    let tokens = text.split(separator: " ").map(String.init)
    var exact: [String] = [], prefix: [String] = [], rest: [String] = []
    for it in items where tokens.allSatisfy({ it.range(of: $0, options: opt) != nil }) {
        if it.compare(text, options: opt) == .orderedSame { exact.append(it) }
        else if it.range(of: text, options: opt.union(.anchored)) != nil { prefix.append(it) }
        else { rest.append(it) }
    }
    return exact + prefix + rest
}

// ---- bar -----------------------------------------------------------------------------------------

func width(_ s: String) -> CGFloat { (s as NSString).size(withAttributes: [.font: font]).width }

final class Bar: NSView {
    var text = "", matches = items, sel = 0
    let pad = width("  ")                                    // left + right padding of a cell
    lazy var inputWidth = min(items.map(width).max() ?? 0, bounds.width / 3) + pad

    override var isFlipped: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    func finish(_ out: String?) {
        if let out { print(out) }
        exit(out == nil ? 1 : 0)
    }
    func update() { matches = filter(text); sel = 0; needsDisplay = true }
    func move(_ d: Int) {
        guard !matches.isEmpty else { return }
        sel = max(0, min(matches.count - 1, sel + d)); needsDisplay = true
    }

    override func keyDown(with e: NSEvent) {
        let mods = e.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let key = e.charactersIgnoringModifiers ?? ""
        if mods.contains(.control) {
            switch key {
            case "n", "j": move(1)
            case "p", "k": move(-1)
            case "u": text = ""; update()
            case "w":
                while text.last == " " { text.removeLast() }
                while let c = text.last, c != " " { text.removeLast() }
                update()
            case "c", "g", "[": finish(nil)
            case "m": finish(matches.isEmpty ? text : matches[sel])
            default: break
            }
            return
        }
        if mods.contains(.command) {
            if key == "v", let s = NSPasteboard.general.string(forType: .string) {
                text += s.replacingOccurrences(of: "\n", with: " "); update()
            }
            return
        }
        switch e.keyCode {
        case 53: finish(nil)                                                       // Esc
        case 36, 76: finish(mods.contains(.shift) || matches.isEmpty ? text : matches[sel])  // Return
        case 51: if !text.isEmpty { text.removeLast(); update() }                  // Backspace
        case 48: if !matches.isEmpty { text = matches[sel]; update() }             // Tab
        case 123, 126: move(-1)                                                    // Left, Up
        case 124, 125: move(1)                                                     // Right, Down
        default:
            if let s = e.characters, !s.isEmpty,
               s.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) && $0.value < 0xF700 }) {
                text += s; update()                                                // 0xF700+: function keys
            }
        }
    }

    // one cell: background (if any), then the string, left-padded; returns its width
    @discardableResult
    func cell(_ s: String, x: CGFloat, y: CGFloat, w: CGFloat? = nil, fg: NSColor, bg: NSColor? = nil) -> CGFloat {
        let cw = w ?? width(s) + pad
        if let bg { bg.setFill(); NSRect(x: x, y: y, width: cw, height: rowHeight).fill() }
        let lh = font.ascender - font.descender
        (s as NSString).draw(at: NSPoint(x: x + pad / 2, y: y + (rowHeight - lh) / 2),
                             withAttributes: [.font: font, .foregroundColor: fg])
        return cw
    }

    override func draw(_ dirty: NSRect) {
        normBg.setFill(); bounds.fill()
        var x: CGFloat = 0
        if !prompt.isEmpty { x += cell(prompt, x: x, y: 0, fg: selFg, bg: selBg) }

        // input and cursor
        let inputW = lines > 0 || matches.isEmpty ? bounds.width - x : inputWidth
        cell(text, x: x, y: 0, w: inputW, fg: normFg)
        normFg.setFill()
        NSRect(x: x + pad / 2 + width(text) + 1, y: (rowHeight - fontSize) / 2, width: 2, height: fontSize).fill()
        x += inputW

        if lines > 0 {                                       // vertical list (-l), one page of `lines` rows
            let start = sel / lines * lines
            for (row, i) in (start..<min(start + lines, matches.count)).enumerated() {
                cell(matches[i], x: 0, y: rowHeight * CGFloat(row + 1), w: bounds.width,
                     fg: i == sel ? selFg : normFg, bg: i == sel ? selBg : nil)
            }
            return
        }
        // horizontal: the page of items that holds the selection, with < > when there are more
        let arrow = width("<") + pad, avail = bounds.width - x - 2 * arrow
        var start = 0, end = 0
        while true {
            var w: CGFloat = 0
            end = start
            while end < matches.count, w + width(matches[end]) + pad <= avail || end == start {
                w += width(matches[end]) + pad; end += 1
            }
            if sel < end || end >= matches.count { break }
            start = end
        }
        if start > 0 { cell("<", x: x, y: 0, fg: normFg) }
        x += arrow
        for i in start..<end {
            x += cell(matches[i], x: x, y: 0, fg: i == sel ? selFg : normFg, bg: i == sel ? selBg : nil)
        }
        if end < matches.count { cell(">", x: bounds.width - arrow, y: 0, fg: normFg) }
    }
}

final class Panel: NSPanel {
    override var canBecomeKey: Bool { true }
    // macOS keeps windows below the menu-bar area; dmenu belongs over the bar, at the very top
    override func constrainFrameRect(_ r: NSRect, to screen: NSScreen?) -> NSRect { r }
    override func resignKey() { super.resignKey(); exit(1) }   // clicked elsewhere: cancel, like losing the grab
}

// ---- main ----------------------------------------------------------------------------------------

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let screen = NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) } ?? NSScreen.main!
let height = rowHeight * CGFloat(lines + 1)
let frame = NSRect(x: screen.frame.minX, y: bottom ? screen.frame.minY : screen.frame.maxY - height,
                   width: screen.frame.width, height: height)
let panel = Panel(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
panel.level = .popUpMenu                                     // above SketchyBar and the menu bar
panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
panel.hasShadow = false
let bar = Bar(frame: NSRect(origin: .zero, size: frame.size))
panel.contentView = bar
panel.makeKeyAndOrderFront(nil)
panel.makeFirstResponder(bar)
app.activate(ignoringOtherApps: true)
app.run()
