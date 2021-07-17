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

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(viewModel: companyViewModel(), saveAction: {})
	}
}
