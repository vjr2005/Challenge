import Foundation

extension HTTPURLResponse {
	static func ok(url: URL) -> HTTPURLResponse? {
		withStatus(200, url: url)
	}

	static func withStatus(_ statusCode: Int, url: URL) -> HTTPURLResponse? {
		HTTPURLResponse(
			url: url,
			statusCode: statusCode,
			httpVersion: nil,
			headerFields: nil,
		)
	}
}
