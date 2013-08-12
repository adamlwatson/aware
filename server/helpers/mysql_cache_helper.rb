module Mysql2
  module EM
    class Client

      def query_with_cache(sql, opts={})
        puts "IN MONKEY PATCH!"
        debugger

        #self.query(sql, opts={})
      end
    end
  end
end
