import SwiftUI

struct ContentView: View {
	@ObservedObject var viewModel: companyViewModel
	@State var searchText = ""
	@Environment(\.scenePhase) private var scenePhase
	let saveAction: () -> Void

	var body: some View{
		TabView{
			NavigationView{
				ScrollView{
					LazyVStack(spacing: 10){
						SearchBar(searchText: $searchText)
						Divider()
						ForEach(viewModel.companies.filter({viewModel.searchResult($0,searchText)}), id: \.self){ company in
							CellView(company: company, viewModel: viewModel)
							Divider()
						}
					}
				}
				.navigationTitle(Text("Stockings"))
			}
			.tabItem{
				Text("Stockings")
				Image(systemName: "doc.text")
			}
			NavigationView{
				ScrollView{
					LazyVStack(spacing: 10){
						SearchBar(searchText: $searchText)
						Divider()
						ForEach(viewModel.companies.filter({viewModel.searchResult($0,searchText) && $0.isFavorite}), id: \.self){ company in
							CellView(company: company, viewModel: viewModel)
							Divider()
						}
					}
				}
				.navigationTitle(Text("Favorites"))
			}
			.tabItem{
				Text("Favorites")
				Image(systemName: "star")
			}
		}
		.onChange(of: scenePhase){ phase in
			if phase == .inactive { saveAction() }
		}
	}
}

struct CellView: View{
	var company: company
	@ObservedObject var viewModel: companyViewModel
	var body: some View{
		HStack(spacing: 12){
			Image("\(company.ticker)")
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: 70, height: 70)
				.clipped()
				.cornerRadius(16)
				.shadow(radius: 2)
			VStack(alignment: .leading, spacing: 5){
				HStack(){
					Text("\(company.ticker)")
						.bold()
					Button(action: {
						viewModel.favoritePressed(company.id)
					}, label: {
						Image(systemName: "star.fill")
							.resizable()
							.frame(width: 16, height: 16)
							.foregroundColor(Color(red: company.buttonColor.r,
												   green: company.buttonColor.g,
												   blue: company.buttonColor.b))

					})
				}
				Text("\(company.name)")
					.font(.subheadline)
			}
			Spacer()
			VStack(alignment: .trailing, spacing: 5){
				Text(company.stockView.currentPrice)
					.bold()
				Text(company.stockView.difference)
					.foregroundColor(Color(red: company.stockView.color.r, green: company.stockView.color.g, blue: company.stockView.color.b))
					.font(.system(size: 14))
					.bold()

			}
		}
		.padding(.horizontal)
	}
}

struct SearchBar: View{
	@Binding var searchText: String

	var body: some View{
		HStack(){
			TextField("Find company or ticker", text: $searchText)
				.autocapitalization(.none)
		}
		.padding(10)
		.background(Color(.systemGray5))
		.cornerRadius(16)
		.padding(.horizontal)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(viewModel: companyViewModel(), saveAction: {})
	}
}
