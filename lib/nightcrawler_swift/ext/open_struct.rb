module NightcrawlerSwift
  module Ext
    module OpenStruct

      unless ::OpenStruct.new.respond_to?(:to_h)
        def to_h
          @table.dup || {}
        end
      end

    end
  end
end

OpenStruct.send :include, NightcrawlerSwift::Ext::OpenStruct
