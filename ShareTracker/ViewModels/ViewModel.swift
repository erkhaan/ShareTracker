import Foundation
import Alamofire
import SwiftyJSON

final class companyViewModel: ObservableObject {
	@Published var companies: [Company]

    init() {
		self.companies = csvImport()
		for i in 0..<companies.count {
			fetchCompanyStocks(i)
		}
	}

	// MARK: - API

	private func fetchCompanyStocks(_ i: Int) {
        let endpointUrl = "https://finnhub.io/api/v1/quote?symbol="
        let apiKey = "&token=c1rvmd2ad3ifb04kehfg"
        let url = endpointUrl + companies[i].ticker + apiKey

		AF.request(url).responseJSON { response in
			switch response.result {
			case .success(let value):
				let json = JSON(value)
				guard let c = json["c"].double else {
					print(json["c"].error!)
					return
				}
				guard let pc = json["pc"].double else {
					print(json["pc"].error!)
					return
				}
				self.companies[i].stock = Response(c: c, pc: pc)
				self.companies[i].stockView = self.stockViewFrom(c: c, pc: pc)
			case .failure(let error):
				print(error)
			}
		}
	}

	// MARK: - Methods

    func favoritePressed(_ i: Int) {
		if companies[i].isFavorite {
			companies[i].buttonColor = RGB(r: 0.5, g: 0.5, b: 0.5)
		} else {
			companies[i].buttonColor = RGB(r: 246/256, g: 197/256, b: 67/256)
		}
		companies[i].isFavorite.toggle()
	}

	// MARK: - Searching

    private func textFound(from b: String, in a: String) -> Bool {
		a.lowercased().contains(b.lowercased())
	}

    func searchResult(_ name: String, _ ticker: String, _ search: String) -> Bool {
        textFound(from: search, in: name + ticker) || search.isEmpty
	}
}

// MARK: - Formatting

extension companyViewModel {
    private func format(currentPrice c: Double) -> String {
		String(format: "$%.2f",c)
	}

    private func format(difference value: Double) -> String {
		let s: String
		if value >= 0.0 {
			s = "+$" + String(format:"%.2f",value)
		} else {
			s = "-$" + String(format:"%.2f",-value)
		}
		return s
	}

    private func format(difference value: Double, to pc: Double) -> String {
		String(format:"(%.2f%%)",value / pc * 100)
	}

    private func formatStockToString(difference value: Double, percent pc: Double) -> String {
		format(difference: value) + " " + format(difference: value, to: pc)
	}

    private func stockColor(from value: Double) -> RGB {
		if value >= 0 {
			return RGB(r: 45/255, g: 173/255, b: 94/255)
		}
		return RGB(r: 1, g: 0, b: 0)
	}

    private func stockViewFrom(c: Double, pc: Double) -> StockInfo {
		var stockView = StockInfo()
		let value = c - pc

		stockView.currentPrice = format(currentPrice: c)
		stockView.difference = formatStockToString(difference: value, percent: pc)
		stockView.color = stockColor(from: value)

		return stockView
	}
}

// MARK: - Persistence

extension companyViewModel {
	private static var documentsFolder: URL {
		do {
			return try FileManager.default.url(for: .documentDirectory,
											   in: .userDomainMask,
											   appropriateFor: nil,
											   create: false)
		} catch {
			fatalError("Can't find document directory")
		}
	}

	private static var fileURL: URL {
        documentsFolder.appendingPathComponent("companies.data")
	}

    func load() {
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let data = try? Data(contentsOf: Self.fileURL) else { return }
			guard let companiesData = try? JSONDecoder().decode([Company].self, from: data) else {
				print("Can't decode saved companies data")
				return
			}
			DispatchQueue.main.async {
				self?.companies = companiesData
			}
		}
	}

    func save() {
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let companies = self?.companies else {
                fatalError("Self out of scope")
            }
			guard let data = try? JSONEncoder().encode(companies) else {
                fatalError("Error encoding data")
            }
			do {
				let outfile = Self.fileURL
				try data.write(to: outfile)
			} catch {
				fatalError("Can't write file")
			}
		}
	}
}
