module Jimmy
  module TransformKeys
    def camel_upper(str)
      camel_lower(str).sub(/\A(.)/) { $1.upcase }
    end

    def camel_lower(str)
      str.gsub(/[-_\s]+(.)/) { $1.upcase }
    end

    class Transformer
      include TransformKeys

      def cache(method)
        (@cache ||= {})[method] ||= {}
      end

      def transform(sym, method)
        if method
          cache(method)[sym] ||= __send__(method, sym.to_s).to_sym
        else
          sym
        end
      end
    end

    def self.transformer
      @transformer ||= Transformer.new
    end
  end
end