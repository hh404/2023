import Foundation

// 原始文件路径
let inputFilePath = "input.txt"
// 结果文件路径
let outputFilePath = "output.txt"

// 读取原始文件内容
if let inputText = try? String(contentsOfFile: inputFilePath, encoding: .utf8) {
    // 分割原始文本为键值对数组
    let keyValuePairs = inputText.components(separatedBy: ", ")
    
    // 创建一个字典来存储键值对，只保留最后的值
    var keyValueDictionary: [String: String] = [:]
    
    for pair in keyValuePairs {
        let components = pair.components(separatedBy: ": ")
        if components.count == 2 {
            let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            keyValueDictionary[key] = value
        }
    }
    
    // 构建结果字符串
    var outputText = ""
    for (key, value) in keyValueDictionary {
        outputText += "\"\(key)\": \"\(value)\", "
    }
    
    // 移除末尾的逗号和空格
    if outputText.hasSuffix(", ") {
        outputText.removeLast(2)
    }
    
    // 将结果写入结果文件
    do {
        try outputText.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        print("结果已成功写入到 \(outputFilePath)")
    } catch {
        print("写入结果文件时发生错误：\(error)")
    }
} else {
    print("无法读取原始文件：\(inputFilePath)")
}