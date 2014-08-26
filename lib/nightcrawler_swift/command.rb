module NightcrawlerSwift
  class Command

    def connection
      NightcrawlerSwift.connection
    end

    def execute
      raise NotImplemented.new
    end

  end
end
