import SwiftUI

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
