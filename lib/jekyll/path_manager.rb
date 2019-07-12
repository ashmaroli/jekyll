# frozen_string_literal: true

module Jekyll
  class PathManager
    class << self
      def join(base, item)
        @join ||= {}
        @join[base] ||= {}
        @join[base][item] ||= File.join(base, item).freeze
      end
    end
  end
end
