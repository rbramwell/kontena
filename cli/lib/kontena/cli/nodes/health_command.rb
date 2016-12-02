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

      if !node['connected']
        exit_with_error "Node is not connected"
      else
        STDERR.puts " [#{pastel.green('ok')}] Node is healthy"
      end
    end
  end
end
