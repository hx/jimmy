module Jimmy
  class TypeReference < Reference
    attr_reader :type

    def initialize(type, domain, *args)
      @type = type
      uri   = domain.root + "types/#{type}.json#"
      path  = uri.path.dup
      path << '?' << uri.query if uri.query
      path << '#' << uri.fragment if uri.fragment
      super path, domain, *args
    end
  end
end
