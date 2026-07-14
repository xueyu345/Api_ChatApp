import Foundation

struct CountryCode: Identifiable, Hashable {
    let id: String
    let name: String
    let flag: String
    let code: String
    
    static let all: [CountryCode] = [
        CountryCode(id: "CN", name: "中国", flag: "🇨🇳", code: "+86"),
        CountryCode(id: "US", name: "美国", flag: "🇺🇸", code: "+1"),
        CountryCode(id: "JP", name: "日本", flag: "🇯🇵", code: "+81"),
        CountryCode(id: "KR", name: "韩国", flag: "🇰🇷", code: "+82"),
        CountryCode(id: "GB", name: "英国", flag: "🇬🇧", code: "+44"),
        CountryCode(id: "FR", name: "法国", flag: "🇫🇷", code: "+33"),
        CountryCode(id: "DE", name: "德国", flag: "🇩🇪", code: "+49"),
        CountryCode(id: "CA", name: "加拿大", flag: "🇨🇦", code: "+1"),
        CountryCode(id: "AU", name: "澳大利亚", flag: "🇦🇺", code: "+61"),
        CountryCode(id: "SG", name: "新加坡", flag: "🇸🇬", code: "+65"),
        CountryCode(id: "HK", name: "香港", flag: "🇭🇰", code: "+852"),
        CountryCode(id: "TW", name: "台湾", flag: "🇹🇼", code: "+886"),
        CountryCode(id: "IN", name: "印度", flag: "🇮🇳", code: "+91"),
        CountryCode(id: "RU", name: "俄罗斯", flag: "🇷🇺", code: "+7"),
        CountryCode(id: "BR", name: "巴西", flag: "🇧🇷", code: "+55"),
        CountryCode(id: "IT", name: "意大利", flag: "🇮🇹", code: "+39"),
        CountryCode(id: "ES", name: "西班牙", flag: "🇪🇸", code: "+34"),
        CountryCode(id: "NL", name: "荷兰", flag: "🇳🇱", code: "+31"),
        CountryCode(id: "SE", name: "瑞典", flag: "🇸🇪", code: "+46"),
        CountryCode(id: "NO", name: "挪威", flag: "🇳🇴", code: "+47"),
        CountryCode(id: "DK", name: "丹麦", flag: "🇩🇰", code: "+45"),
        CountryCode(id: "FI", name: "芬兰", flag: "🇫🇮", code: "+358"),
        CountryCode(id: "CH", name: "瑞士", flag: "🇨🇭", code: "+41"),
        CountryCode(id: "NZ", name: "新西兰", flag: "🇳🇿", code: "+64"),
        CountryCode(id: "MY", name: "马来西亚", flag: "🇲🇾", code: "+60"),
        CountryCode(id: "TH", name: "泰国", flag: "🇹🇭", code: "+66"),
        CountryCode(id: "VN", name: "越南", flag: "🇻🇳", code: "+84"),
        CountryCode(id: "PH", name: "菲律宾", flag: "🇵🇭", code: "+63"),
    ]
}
