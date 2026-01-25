import Foundation

extension HTTPURLResponse {
	static func withStatus(_ statusCode: Int, url: URL) -> HTTPURLResponse? {
		HTTPURLResponse(
			url: url,
			statusCode: statusCode,
			httpVersion: nil,
			headerFields: nil,
		)
	}
}
