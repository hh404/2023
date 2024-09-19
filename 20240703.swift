struct RemittanceView: View {
    var body: some View {
        VStack(spacing: 20) {
            RemittanceCard(title: "Title 1", arrivalTime: "1-3 Days", fee: "SGD 20")
            RemittanceCard(title: "Title 2", arrivalTime: "Instant", fee: "Free")
        }
        .padding()
    }
}

struct RemittanceCard: View {
    var title: String
    var arrivalTime: String
    var fee: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Should Arrive")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(arrivalTime)
                        .font(.body)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Remittance fees")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(fee)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}