module NightcrawlerSwift
  module Ext
    module NilClass

      unless nil.respond_to?(:to_h)
        def to_h
          {}
        end
      end

    end
  end
end

NilClass.send :include, NightcrawlerSwift::Ext::NilClass
