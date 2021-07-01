import Foundation

class companyViewModel: ObservableObject{
	// Persistence
	private static var documentsFolder: URL{
		do {
			return try FileManager.default.url(for: .documentDirectory,
											   in: .userDomainMask,
											   appropriateFor: nil,
											   create: false)
		} catch  {
			fatalError("Can't find document directory")
		}
	}

	private static var fileURL: URL{
		return documentsFolder.appendingPathComponent("companies.data")
	}


	@Published var companies: [company] = csvImport()

	init(){
		for i in 0..<companies.count{
			fetchCompanyStocks(i)
		}
	}

	func load(){
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let data = try? Data(contentsOf: Self.fileURL) else { return }
			guard let companiesData = try? JSONDecoder().decode([company].self, from: data) else{
				print("Can't decode saved companies data")
				return
			}
			DispatchQueue.main.async {
				self?.companies = companiesData
			}
		}
	}

	func save(){
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let companies = self?.companies else { fatalError("Self out of scope")}
			guard let data = try? JSONEncoder().encode(companies) else { fatalError("Error encoding data")}
			do{
				let outfile = Self.fileURL
				try data.write(to: outfile)
			} catch{
				fatalError("Can't write file")
			}
		}
	}

	// API Call

	func fetchCompanyStocks(_ i: Int){
		let link = "https://finnhub.io/api/v1/quote?symbol="+self.companies[i].ticker+"&token=c1rvmd2ad3ifb04kehfg"
		guard let url = URL(string: link) else{
			return
		}

		URLSession.shared.dataTask(with: url){
			data, _, error in
			guard let data = data, error == nil else{
				return
			}
			if let ans = try? JSONDecoder().decode(Response.self, from: data){
				DispatchQueue.main.async{
					self.companies[i].stock = ans
					self.companies[i].stockView = self.getStockView(c: ans.c, pc: ans.pc)
				}
			}else{
				print("invalid")
			}
		}.resume()
	}

	// Methods 

	func favoritePressed(_ i: Int){
		if(companies[i].isFavorite){
			companies[i].buttonColor = RGB(r: 0.5, g: 0.5, b: 0.5)
		}else{
			companies[i].buttonColor = RGB(r: 246/256, g: 197/256, b: 67/256)
		}
		companies[i].isFavorite.toggle()
	}

	func searchResult(_ someCompany: company, _ searchText: String) -> Bool{
		let a: Bool = someCompany.name.lowercased().contains(searchText.lowercased())
		let b: Bool = someCompany.ticker.lowercased().contains(searchText.lowercased())
		let c: Bool = searchText.isEmpty
		return a || b || c
	}

	func formatCurrentPrice(_ c: Double) -> String{
		String(format: "$%.2f",c)
	}

	func formatDifference(_ value: Double) -> String{
		var s: String
		if value >= 0.0{
			s = "+$" + String(format:"%.2f",value)
		}else{
			s = "-$" + String(format:"%.2f",-value)
		}
		return s
	}

	func formatDifferenceInPercent(value: Double, pc: Double) -> String{
		return String(format:"(%.2f%%)",value/pc*100)
	}

	func getStockDifferenceInString(value: Double, pc: Double) -> String{
		return formatDifference(value) + " " + formatDifferenceInPercent(value: value, pc: pc)
	}

	func getStockColor(_ value: Double) -> RGB{
		if value >= 0{
			return RGB(r: 45/255, g: 173/255, b: 94/255)
		}
		return RGB(r: 1, g: 0, b: 0)
	}

	func getStockView(c: Double, pc: Double) -> stockInfo{
		var stockView = stockInfo()
		let value = c - pc

		stockView.currentPrice = formatCurrentPrice(c)
		stockView.difference = getStockDifferenceInString(value: value, pc: pc)
		stockView.color = getStockColor(value)

		return stockView
	}
}
