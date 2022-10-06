import Foundation

struct Company: Codable, Hashable, Identifiable {
    var id: Int = 0
    let ticker: String
    let name: String
    var stock: Response = Response(c: 0, pc: 0)
    var stockView = StockInfo()
    var isFavorite: Bool = false
    var buttonColor: RGB = RGB(r: 0.5, g: 0.5, b: 0.5)
}

struct StockInfo: Codable, Hashable {
    var currentPrice: String = "none"
    var difference: String = "none"
    var color: RGB = RGB()
}

/// c - current price
/// pc - previous close price

struct Response: Codable, Hashable {
    let c: Double
    let pc: Double
}

struct RGB: Codable, Hashable {
    var r: Double = 0
    var g: Double = 0
    var b: Double = 0
}

/// Quote real-time quote for US stocks
/// {"c":132.03,"h":135,"l":131.655,"o":134.94,"pc":134.43,"t":1618430402}
/// c - current price
/// o - open price
/// pc - previous close price
/// h,l - high/low price

func csvImport() -> [Company] {
    var companyList = [Company]()
    
    guard let filepath = Bundle.main.path(forResource: "constituents", ofType: "csv") else {
        return [Company]()
    }
    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        print(error)
        return [Company]()
    }
    var rows = data.components(separatedBy: "\n")
    rows.removeFirst()
    var index = 0
    for row in rows {
        let columns = row.components(separatedBy: ",")
        var tmp = Company(id: index, ticker: columns[0], name: columns[1])
        index += 1
        companyList.append(tmp)
    }
    return companyList
}
