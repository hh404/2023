struct ContentView: View {
    @State private var cardNumber: String = "123456"
    @State private var cardHolder: String = "56789"
    @State private var expiryDate: String = "05 / 25"
    @State private var cvv: String = "123"
    @State private var isCvvVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) { // 可以调整这里的间距来改变“账号”和其值之间的间距
                   Text("账号")
                       .font(.caption)
                   Text(cardNumber)
               }
               .padding(.bottom, 0) // 调整这个值来改变与下一个文本的间距
            
            VStack(alignment: .leading, spacing: 0) { //
            Text("卡号")
            Text(cardHolder)
                //.padding(.bottom, 10)
            }
            
            HStack(spacing: 10) {
                VStack(alignment: .leading) {
                    Text("过期时间")
                    Text(expiryDate)
                }
                
                VStack(alignment: .leading) {
                    Text("cvv")
                    HStack {
                        Text(isCvvVisible ? cvv : String(repeating: "•", count: cvv.count))
                        Button(action: {
                            self.isCvvVisible.toggle()
                        }) {
                            Image(systemName: isCvvVisible ? "eye.slash.fill" : "eye.fill")
                        }
                        .padding(.leading, 5) // Provides space between the CVV text and the eye icon
                    }
                }
                .padding(.leading, 10) // Space between expiry date and cvv fields
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}