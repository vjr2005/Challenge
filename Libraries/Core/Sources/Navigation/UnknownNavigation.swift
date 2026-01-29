/// Navigation destination for unhandled routes.
/// Used as a fallback when an OutgoingNavigation has no registered redirect.
public enum UnknownNavigation: IncomingNavigation {
    case notFound
}
