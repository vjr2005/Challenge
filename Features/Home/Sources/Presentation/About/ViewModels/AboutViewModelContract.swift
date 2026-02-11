protocol AboutViewModelContract: AnyObject {
	var info: AboutInfo { get }
	func didAppear()
	func didTapClose()
}
