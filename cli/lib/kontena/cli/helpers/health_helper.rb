module Kontena::Cli::Helpers
  module HealthHelper
    # Validate grid/nodes configuration for etcd operation
    # @param grid [Hash] get(/grids/:grid) => { ... }
    # @param nodes [Array<Hash>] get(/grids/:grid/nodes)[nodes] => [ { ... } ]
    def show_grid_health(grid, nodes)
      initial_nodes = grid['initial_size']
      minimum_nodes = grid['initial_size'] / 2 + 1 # a majority is required for etcd quorum

      initial_nodes_created = 0
      initial_nodes_connected = 0

      nodes.each do |node|
        initial_nodes_created += 1 if node['initial_member']
        initial_nodes_connected += 1 if node['initial_member'] && node['connected']
      end

      if initial_nodes_created < minimum_nodes
        log_error "Grid only has #{initial_nodes_created} of #{grid['initial_size']} initial nodes created, and requires at least #{minimum_nodes} nodes to operate"

      elsif initial_nodes_connected < minimum_nodes
        log_error "Grid only has #{initial_nodes_connected} of #{grid['initial_size']} initial nodes connected, and requires at least #{minimum_nodes} nodes to operate"

      elsif initial_nodes_created < initial_nodes
        warning "Grid only has #{initial_nodes_created} of #{grid['initial_size']} initial nodes created, and requires at least #{minimum_nodes} nodes to operate"

      elsif initial_nodes_connected < initial_nodes
        warning "Grid only has #{initial_nodes_connected} of #{grid['initial_size']} initial nodes connected, and requires at least #{minimum_nodes} nodes to operate"

      end
    end

    # Check node health
    #
    # @param node [Hash] get(/nodes/:grid/:node)
    # @return [Boolean] false if unhealthy
    def check_node_health(node)
      if !node['connected']
        yield :error, "Node is not connected"
        return false
      else
        yield :ok, "Node is connected"
        return true
      end
    end

    HEALTH_SYMBOL = "●"

    def health_symbol(sym)
      case sym
      when :ok
        pastel.green(HEALTH_SYMBOL)
      when :warning
        pastel.yellow(HEALTH_SYMBOL)
      when :error
        pastel.red(HEALTH_SYMBOL)
      else
        pastel.grey(HEALTH_SYMBOL)
      end
    end

    def log_health(sym, msg)
      STDERR.puts "#{health_symbol(sym)} #{msg}"
    end
  end
end
