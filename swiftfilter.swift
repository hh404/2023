import Foundation

// 读取a.txt文件内容
if let aText = try? String(contentsOfFile: "a.txt", encoding: .utf8),
   let bText = try? String(contentsOfFile: "b.txt", encoding: .utf8) {
    
    // 将a.txt的内容解析为字典
    var aDictionary: [String: String] = [:]
    let aLines = aText.components(separatedBy: "\n")
    for line in aLines {
        let components = line.components(separatedBy: ":")
        if components.count == 2 {
            let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            aDictionary[key] = value
        }
    }
    
    // 解析b.txt的内容并过滤出匹配的键值对
    var filteredLines: [String] = []
    let bLines = bText.components(separatedBy: "\n")
    for line in bLines {
        let components = line.components(separatedBy: ":")
        if components.count == 2 {
            let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            if let aValue = aDictionary[key] {
                let filteredLine = "\"\(key)\": \"\(aValue)\""
                filteredLines.append(filteredLine)
            }
        }
    }
    
    // 将过滤后的内容写入c.txt文件
    let filteredText = filteredLines.joined(separator: "\n")
    do {
        try filteredText.write(toFile: "c.txt", atomically: true, encoding: .utf8)
        print("已创建 c.txt 文件")
    } catch {
        print("写入 c.txt 文件时出错：\(error)")
    }
} else {
    print("无法读取 a.txt 或 b.txt 文件")
}