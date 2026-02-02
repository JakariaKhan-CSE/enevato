import WidgetKit
import SwiftUI

struct SummaryEntry: TimelineEntry {
    let date: Date
    let balance: String
    let sales: String
}

struct SummaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> SummaryEntry {
        SummaryEntry(date: Date(), balance: "$0.00", sales: "0")
    }

    func getSnapshot(in context: Context, completion: @escaping (SummaryEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SummaryEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> SummaryEntry {
        let defaults = UserDefaults(suiteName: "group.com.example.myenvato")
        let balance = defaults?.string(forKey: "summary_balance") ?? "—"
        let salesValue = defaults?.integer(forKey: "summary_sales") ?? 0
        return SummaryEntry(
            date: Date(),
            balance: balance,
            sales: "\(salesValue)"
        )
    }
}

struct SummaryWidgetEntryView: View {
    var entry: SummaryProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Evacado Tracker")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Summary")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.balance)
                        .font(.title3)
                        .bold()
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(entry.sales)
                        .font(.title3)
                        .bold()
                    Text("Sales")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

@main
struct SummaryWidget: Widget {
    let kind: String = "SummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SummaryProvider()) { entry in
            SummaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Evacado Summary")
        .description("Shows balance and sales.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
