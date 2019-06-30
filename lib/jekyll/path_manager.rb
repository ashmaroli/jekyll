# frozen_string_literal: true

module Jekyll
  class PathManager
    class << self
      def join(base, item)
        @join ||= {}
        @join[base] ||= {}
        @join[base][item] ||= File.join(base, item).freeze
      end

      def sanitized_join(base, input)
        @sanitized_join ||= {}
        @sanitized_join[base] ||= {}
        @sanitized_join[base][input] ||= begin
          input = input.dup
          input.insert(0, "/") if input.start_with?("~")
          input = File.expand_path(input, "/")

          if input.eql?(base)
            input
          else
            # remove any remaining extra leading slashes not stripped away by calling
            # `File.expand_path` above.
            input.squeeze!("/")

            if input.start_with?("#{base}/")
              input
            else
              input.sub!(%r!\A\w:/!, "/")
              join(base, input).freeze
            end
          end
        end
      end
    end
  end
end
