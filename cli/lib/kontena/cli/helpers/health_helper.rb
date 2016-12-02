module Kontena::Cli::Helpers
  module HealthHelper
    HEALTH_SYMBOL = "●"

    def health_symbol(sym)
      case sym
      when nil
        " "
      when :ok
        pastel.green(HEALTH_SYMBOL)
      when :warning
        pastel.yellow(HEALTH_SYMBOL)
      when :error
        pastel.red(HEALTH_SYMBOL)
      else
        pastel.dark(HEALTH_SYMBOL)
      end
    end

    # Validate grid nodes configuration and status
    #
    def check_grid_health(grid, nodes)
      initial = grid['initial_size']
      minimum = grid['initial_size'] / 2 + 1 # a majority is required for etcd quorum

      nodes = nodes.select{|node| node['initial_member']}
      connected_nodes = nodes.select{|node| node['connected']}

      if connected_nodes.length < minimum
        health = :error
      elsif connected_nodes.length < initial
        health = :warning
      else
        health = :ok
      end

      return {
        initial: initial,
        minimum: minimum,
        nodes: nodes,
        connected: connected_nodes.length,
        health: health,
      }
    end

    # Validate grid/nodes configuration for etcd operation
    # @param grid [Hash] get(/grids/:grid) => { ... }
    # @param nodes [Array<Hash>] get(/grids/:grid/nodes)[nodes] => [ { ... } ]
    # @return [Boolean] false if unhealthy
    def show_grid_health(grid, nodes)
      grid_health = check_grid_health(grid, nodes)

      if grid_health[:nodes].length < grid_health[:minimum]
        yield :error, "Grid only has #{grid_health[:created]} of #{grid_health[:minimum]} initial nodes, and will not operate"
      elsif grid_health[:nodes].length < grid_health[:initial]
        yield :warning, "Grid only has #{grid_health[:created]} of #{grid_health[:initial]} initial nodes, and will not be high-availability"
      end

      grid_health[:nodes].each do |node|
        if !node['connected']
          yield grid_health[:health], "Initial node #{node['name']} is disconnected"
        else
          yield :ok, "Initial node #{node['name']} is connected"
        end
      end

      return grid_health[:health] == :ok
    end

    # Check node health
    #
    # @param node [Hash] get(/nodes/:grid/:node)
    # @return [Boolean] false if unhealthy
    def show_node_health(node)
      if !node['connected']
        yield :error, "Node is not connected"
        return false
      else
        yield :ok, "Node is connected"
        return true
      end
    end
  end
end
