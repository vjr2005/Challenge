import Foundation

extension URLRequest {
	/// Returns body data from either `httpBody` or `httpBodyStream`.
	/// URLSession may convert `httpBody` to a stream, so we need to check both.
	var bodyData: Data? {
		if let httpBody {
			return httpBody
		}

		guard let stream = httpBodyStream else {
			return nil
		}

		stream.open()
		defer { stream.close() }

		var data = Data()
		let bufferSize = 1024
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
		defer { buffer.deallocate() }

		while stream.hasBytesAvailable {
			let bytesRead = stream.read(buffer, maxLength: bufferSize)
			if bytesRead > 0 {
				data.append(buffer, count: bytesRead)
			} else {
				break
			}
		}

		return data
	}
}
