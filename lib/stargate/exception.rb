class Stargate::Exception < StandardError; end

class Stargate::ConnectionNotEstablishedError < Stargate::Exception; end

class Stargate::ConnectionTimeoutError < Stargate::Exception; end

class Stargate::TableNotFoundError < Stargate::Exception; end

class Stargate::TableError < Stargate::Exception; end

class Stargate::TableExistsError < Stargate::Exception; end

class Stargate::TableCreationError < Stargate::Exception; end

class Stargate::TableNotDisabledError < Stargate::Exception; end

class Stargate::TableFailDisableError < Stargate::Exception; end

class Stargate::TableFailEnableError < Stargate::Exception; end

class Stargate::RowNotFoundError < Stargate::Exception; end

class Stargate::ScannerError < Stargate::Exception; end
