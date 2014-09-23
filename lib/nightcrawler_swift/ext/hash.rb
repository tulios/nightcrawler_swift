module NightcrawlerSwift
  module Hash

    unless {}.respond_to?(:symbolize_keys)
      def symbolize_keys
        {}.tap do |result|
          keys.each {|k| result[k.to_sym] = self[k]}
        end
      end

      def symbolize_keys!
        self.tap do
          keys.each {|k| self[k.to_sym] = delete(k)}
        end
      end
    end

    unless {}.respond_to?(:compact)
      def compact
        {}.tap do |result|
          keys.each {|k| result[k] = self[k] unless self[k].nil?}
        end
      end

      def compact!
        self.tap do
          keys.each do |k|
            value = delete(k)
            self[k] = value unless value.nil?
          end
        end
      end
    end

  end
end

Hash.send :include, NightcrawlerSwift::Hash
