import AppKit
import SwiftUI

struct ClipboardGridView: View {
    @ObservedObject var store: ClipboardStore
    let onChoose: (ClipboardItem) -> Void
    let onClose: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 185, maximum: 240), spacing: 14),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xFDFCFB), Color(hex: 0xF4F7FC)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider().opacity(0.55)

                if store.items.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(Array(store.items.prefix(ShortcutMap.labels.count).enumerated()), id: \.element.id) { index, item in
                                ClipboardCard(
                                    item: item,
                                    shortcut: ShortcutMap.labels[index],
                                    onChoose: { onChoose(item) },
                                    onDelete: { store.delete(item) }
                                )
                            }
                        }
                        .padding(22)
                    }
                    .scrollIndicators(.never)
                }

                footer
            }
        }
        .frame(minWidth: 820, minHeight: 540)
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x6C63FF), Color(hex: 0xFF6F91)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("ClipGrid")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("Choose a clip with its key")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 7) {
                Circle()
                    .fill(store.isPaused ? Color.orange : Color.green)
                    .frame(width: 7, height: 7)
                Text(store.isPaused ? "MONITORING PAUSED" : "MONITORING CLIPBOARD")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.75), in: Capsule())
            .overlay(Capsule().stroke(.black.opacity(0.07)))

            Text("\(store.items.count) saved")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 30, height: 30)
                    .background(.black.opacity(0.055), in: Circle())
            }
            .buttonStyle(.plain)
            .help("Close (Esc)")
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 17)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle().fill(Color(hex: 0xECEBFF))
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Color(hex: 0x6C63FF))
            }
            .frame(width: 82, height: 82)
            Text("Your copied values will appear here")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text("Copy text, links, images, or files with ⌘C.\nClipGrid watches the pasteboard locally and privately.")
                .multilineTextAlignment(.center)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack(spacing: 18) {
            Label("1–9, then A–Z to copy", systemImage: "keyboard")
            Label("Esc to close", systemImage: "escape")
            Spacer()
            Text("⌥⌘C")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
            Text("opens ClipGrid anywhere")
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(.white.opacity(0.7))
        .overlay(alignment: .top) { Divider().opacity(0.55) }
    }
}

private struct ClipboardCard: View {
    let item: ClipboardItem
    let shortcut: String
    let onChoose: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardGradient)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: palette.shadow.opacity(isHovering ? 0.24 : 0.12), radius: isHovering ? 16 : 8, y: isHovering ? 8 : 4)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(shortcut)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(palette.ink)
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white))

                    sourceBadge

                    Spacer()
                    Color.clear.frame(width: 25, height: 25)
                }

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                HStack {
                    Text(relativeDate)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(palette.ink.opacity(0.55))
                    Spacer()
                    Image(systemName: "arrow.turn.down.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(palette.ink.opacity(isHovering ? 0.85 : 0.4))
                }
            }
            .padding(14)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(palette.ink.opacity(0.6))
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(isHovering ? 0.88 : 0.58), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(11)
            .help("Delete this clip")
        }
        .frame(height: 172)
        .scaleEffect(isHovering ? 1.018 : 1)
        .animation(.easeOut(duration: 0.16), value: isHovering)
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture(perform: onChoose)
        .onHover { isHovering = $0 }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(shortcut), \(item.accessibilitySummary)")
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var content: some View {
        switch item.kind {
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 82)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text(item.text)
            }
        case .files:
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.filePaths.count) file\(item.filePaths.count == 1 ? "" : "s")")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(item.text)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(4)
            }
            .foregroundStyle(palette.ink)
        case .link:
            VStack(alignment: .leading, spacing: 7) {
                Text(URL(string: item.text)?.host() ?? "Web link")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(item.text)
                    .font(.system(size: 10, design: .monospaced))
                    .lineLimit(4)
            }
            .foregroundStyle(palette.ink)
        case .text:
            Text(item.text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.ink)
                .lineLimit(6)
                .lineSpacing(2)
        }
    }

    private var sourceBadge: some View {
        HStack(spacing: 6) {
            if let data = item.sourceIconData, let icon = NSImage(data: data) {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: item.kind.symbol)
                    .font(.system(size: 11, weight: .bold))
                    .frame(width: 20, height: 20)
                    .background(.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 5))
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(item.sourceAppName ?? "Copied value")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .lineLimit(1)
                Text(item.kind.label)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .opacity(0.58)
            }
        }
        .foregroundStyle(palette.ink.opacity(0.78))
    }

    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: item.copiedAt, relativeTo: Date())
    }

    private var palette: CardPalette {
        CardPalette.all[item.colorIndex % CardPalette.all.count]
    }

    private var cardGradient: LinearGradient {
        LinearGradient(colors: palette.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private struct CardPalette {
    let colors: [Color]
    let ink: Color
    let shadow: Color

    static let all: [CardPalette] = [
        .init(colors: [Color(hex: 0xE9E5FF), Color(hex: 0xF5F1FF)], ink: Color(hex: 0x3E347A), shadow: Color(hex: 0x7668CE)),
        .init(colors: [Color(hex: 0xDDF8ED), Color(hex: 0xEEFFF8)], ink: Color(hex: 0x185F4A), shadow: Color(hex: 0x3AAE87)),
        .init(colors: [Color(hex: 0xFFE5EC), Color(hex: 0xFFF3F6)], ink: Color(hex: 0x7C3048), shadow: Color(hex: 0xDC6C91)),
        .init(colors: [Color(hex: 0xE1F1FF), Color(hex: 0xF0F8FF)], ink: Color(hex: 0x245A83), shadow: Color(hex: 0x4A9AD6)),
        .init(colors: [Color(hex: 0xFFF0D6), Color(hex: 0xFFF9EC)], ink: Color(hex: 0x76501D), shadow: Color(hex: 0xE5A844)),
        .init(colors: [Color(hex: 0xE7F4D9), Color(hex: 0xF6FCEB)], ink: Color(hex: 0x466126), shadow: Color(hex: 0x83B24D)),
        .init(colors: [Color(hex: 0xF2E4FF), Color(hex: 0xFBF2FF)], ink: Color(hex: 0x66317D), shadow: Color(hex: 0xB96ED4)),
        .init(colors: [Color(hex: 0xFFE8D9), Color(hex: 0xFFF5ED)], ink: Color(hex: 0x7B4025), shadow: Color(hex: 0xE17D50)),
        .init(colors: [Color(hex: 0xDFF7F8), Color(hex: 0xF0FFFF)], ink: Color(hex: 0x215E61), shadow: Color(hex: 0x4AADB1)),
        .init(colors: [Color(hex: 0xECECEC), Color(hex: 0xFAFAFA)], ink: Color(hex: 0x414141), shadow: Color(hex: 0x8A8A8A)),
    ]
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
