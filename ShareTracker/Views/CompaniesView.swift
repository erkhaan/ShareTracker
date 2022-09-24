//
//  CompaniesView.swift
//  ShareTracker
//
//  Created by Erkhaan on 21.07.2021.
//

import SwiftUI

struct CompaniesView: View {
    var companies: [Company]
    @Binding var searchText: String
    @ObservedObject var viewModel: companyViewModel
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                SearchBar(searchText: $searchText)
                Divider()
                ForEach(companies, id: \.self) { company in
                    CellView(company: company, viewModel: viewModel)
                    Divider()
                }
            }
        }
    }
}
