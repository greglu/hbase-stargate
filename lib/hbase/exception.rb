class HBase::Exception < StandardError; end

class HBase::ConnectionNotEstablishedError < HBase::Exception; end

class HBase::ConnectionTimeoutError < HBase::Exception; end

class HBase::TableNotFoundError < HBase::Exception; end

class HBase::TableExistsError < HBase::Exception; end

class HBase::TableFailCreateError < HBase::Exception; end

class HBase::TableNotDisabledError < HBase::Exception; end

class HBase::TableFailDisableError < HBase::Exception; end

class HBase::TableFailEnableError < HBase::Exception; end

class HBase::RowNotFoundError < HBase::Exception; end
