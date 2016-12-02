require_relative '../helpers/health_helper'

module Kontena::Cli::Nodes
  class HealthCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions
    include Kontena::Cli::Helpers::HealthHelper

    parameter "NODE_ID", "Node id"

    def execute
      require_api_url
      require_current_grid
      token = require_token

      node = client(token).get("nodes/#{current_grid}/#{node_id}")

      return show_node_health(node) do |sym, msg|
        STDOUT.puts "#{health_symbol(sym)} #{msg}"
      end
    end
  end
end
