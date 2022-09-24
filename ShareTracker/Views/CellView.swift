import SwiftUI

struct CellView: View {
    var company: Company
    @ObservedObject var viewModel: companyViewModel
    var body: some View {
        HStack(spacing: 12) {
            companyInfoView(company: company, viewModel: viewModel)
            Spacer()
            companyStockView(company: company)
        }
        .padding(.horizontal)
    }
}

struct TickerImageView: View {
    var ticker: String
    var body: some View {
        Image("\(ticker)")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 70, height: 70)
            .clipped()
            .cornerRadius(16)
            .shadow(radius: 2)
    }
}

struct FavoriteIconImageView: View {
    let color: RGB
    var body: some View{
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(Color(red: color.r,
                                   green: color.g,
                                   blue: color.b))
    }
    
}

struct companyInfoView: View {
    var company: Company
    @ObservedObject var viewModel: companyViewModel
    var body: some View {
        TickerImageView(ticker: company.ticker)
        VStack(alignment: .leading, spacing: 5) {
            HStack() {
                Text("\(company.ticker)")
                    .bold()
                Button(action: {
                    viewModel.favoritePressed(company.id)
                }, label: {
                    FavoriteIconImageView(color: company.buttonColor)
                })
            }
            Text("\(company.name)")
                .font(.subheadline)
        }
    }
}

struct companyStockView: View {
    var company: Company
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(company.stockView.currentPrice)
                .bold()
            Text(company.stockView.difference)
                .foregroundColor(Color(
                    red: company.stockView.color.r,
                    green: company.stockView.color.g,
                    blue: company.stockView.color.b))
                .font(.system(size: 14))
                .bold()
        }
    }
}
