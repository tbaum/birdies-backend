require 'net/http'
require 'sinatra'

module BirdiesBackend

  class App < Sinatra::Base

    get '/' do
      "<h1>Simple-App-:</h1>
      <ul>
      <li><a href='create'>./create -> create-node</a></li>
      <li><a href='list'>./list -> all-nodes</a></li>
      </ul>"
    end

    get "/list" do
      "<h1>all nodes</h1>" +
          Neo4j.all_nodes.collect do |node|
            "#{node.id}: #{node}<br/>" unless node == Neo4j.ref_node
          end.join
    end

    get "/create" do
      person = Neo4j::Transaction.run { Person.new }
      Neo4j::Transaction.run { person.name = 'kalle' }

      "created #{person}"
    end
  end


  module API

    module ClassMethods

      def server_url=(url)
        @server_url = URI.parse(url)
      end

      def server_url
        @server_url || URI.parse('http://localhost:7474')
      end


      def update_tweets(tweets)
        server_call('BirdiesBackend', 'update_tweets', tweets)
        JSON.parse(result)['return']
      end

      def server_eval(s)
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.post('/script/jruby/eval', s)
        end
        [res.code, res.body]
      end

      def server_call(clazz, method, value)
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.post("/script/jruby/cal?classandmethod=#{clazz}.#{method}", value)
        end
        [res.code, res.body]
      end

    end

    extend ClassMethods

  end
end
