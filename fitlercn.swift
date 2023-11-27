import Foundation

let fileManager = FileManager.default
let currentDirectoryPath = fileManager.currentDirectoryPath

// 定义文件路径
let enJsonPath = "\(currentDirectoryPath)/en.json"
let cnJsonPath = "\(currentDirectoryPath)/cn.json"
let outputPath = "\(currentDirectoryPath)/filtered_cn.json"

// 读取文件内容
func readJsonFile(atPath path: String) -> [String: String]? {
    guard let jsonData = fileManager.contents(atPath: path) else { return nil }
    do {
        let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String]
        return jsonDict
    } catch {
        print("Error reading JSON file: \(error)")
        return nil
    }
}

// 将字典写入JSON文件
func writeJsonFile(dictionary: [String: String], toPath path: String) {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        fileManager.createFile(atPath: path, contents: jsonData, attributes: nil)
    } catch {
        print("Error writing JSON file: \(error)")
    }
}

// 使用en.json的键过滤cn.json
func filterJson(enDict: [String: String], cnDict: [String: String]) -> [String: String] {
    var filteredDict = [String: String]()
    for key in enDict.keys {
        if let value = cnDict[key] {
            filteredDict[key] = value
        }
    }
    return filteredDict
}

// 执行过滤操作并写入新文件
if let enDict = readJsonFile(atPath: enJsonPath),
   let cnDict = readJsonFile(atPath: cnJsonPath) {
    let filteredDict = filterJson(enDict: enDict, cnDict: cnDict)
    writeJsonFile(dictionary: filteredDict, toPath: outputPath)
    print("Filtered JSON has been written to \(outputPath)")
} else {
    print("Failed to read JSON files.")
}
