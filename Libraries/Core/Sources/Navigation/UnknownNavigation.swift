/// Navigation destination for unhandled routes.
/// Used as a fallback when an OutgoingNavigationContract has no registered redirect.
public enum UnknownNavigation: IncomingNavigationContract {
    case notFound
}
