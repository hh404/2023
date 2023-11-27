import Foundation

let fileManager = FileManager.default
let currentDirectoryPath = fileManager.currentDirectoryPath

// 定义文件路径
let enFilePath = "\(currentDirectoryPath)/en"
let cnFilePath = "\(currentDirectoryPath)/cn"
let outputPath = "\(currentDirectoryPath)/filtered_cn"

// 读取文件内容
func readFile(atPath path: String) -> String? {
    do {
        return try String(contentsOfFile: path, encoding: .utf8)
    } catch {
        print("Error reading file: \(error)")
        return nil
    }
}

// 解析内容为键值对
func parseContent(content: String) -> [String: String] {
    var dict = [String: String]()
    let lines = content.split(separator: "\n")
    for line in lines {
        let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        if components.count == 2 {
            let key = String(components[0]).trimmingCharacters(in: .whitespaces)
            let value = String(components[1]).trimmingCharacters(in: .whitespaces)
            dict[key] = value
        }
    }
    return dict
}

// 写入文件
func writeFile(content: String, toPath path: String) {
    do {
        try content.write(toFile: path, atomically: true, encoding: .utf8)
    } catch {
        print("Error writing file: \(error)")
    }
}

// 执行过滤操作并写入新文件
if let enContent = readFile(atPath: enFilePath),
   let cnContent = readFile(atPath: cnFilePath) {
    let enDict = parseContent(content: enContent)
    let cnDict = parseContent(content: cnContent)
    let filteredContent = cnDict
        .filter { enDict.keys.contains($0.key) }
        .map { "\($0.key): \($0.value)" }
        .joined(separator: "\n")
    writeFile(content: filteredContent, toPath: outputPath)
    print("Filtered content has been written to \(outputPath)")
} else {
    print("Failed to read files.")
}
