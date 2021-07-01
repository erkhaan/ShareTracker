//
//  ShareTrackerApp.swift
//  ShareTracker
//
//  Created by Erkhaan on 15.04.2021.
//

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
