import SwiftUI

@main
struct ShareTrackerApp: App {
	@ObservedObject private var viewModel = companyViewModel()
	var body: some Scene {
		WindowGroup {
			ContentView(viewModel: viewModel){
				viewModel.save()
			}
				.onAppear(){
					viewModel.load()
				}
		}
	}
}
