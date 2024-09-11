# frozen_string_literal: true

module Jekyll
  module Commands
    class Foo < Command
      def self.init_with_program(prog)
        prog.command(:foo) do |c|
          c.syntax "foo [options]"
          c.option "ignore", "--ignore PAT[,PAT2[,...]]", Array, "Files to ignore"

          c.action do |args, opts|
            p args
            p opts
          end
        end
      end
    end
  end
end
