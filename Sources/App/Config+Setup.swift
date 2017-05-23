import FluentProvider
import MySQLProvider
extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    private func setupProviders() throws {
        try addProvider(MySQLProvider.Provider.self)
    }

    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(Session.self)
    }
}
