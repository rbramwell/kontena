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
      initial_nodes = grid['initial_size']
      minimum_nodes = grid['initial_size'] / 2 + 1 # a majority is required for etcd quorum

      initial_nodes_created = 0
      initial_nodes_connected = 0

      nodes.each do |node|
        initial_nodes_created += 1 if node['initial_member']
        initial_nodes_connected += 1 if node['initial_member'] && node['connected']
      end

      if initial_nodes_connected < minimum_nodes
        health = :error
      elsif initial_nodes_connected < initial_nodes
        health = :warning
      else
        health = :ok
      end

      return {
        initial: initial_nodes,
        minimum: minimum_nodes,
        created: initial_nodes_created,
        connected: initial_nodes_connected,
        health: health,
      }
    end

    # Validate grid/nodes configuration for etcd operation
    # @param grid [Hash] get(/grids/:grid) => { ... }
    # @param nodes [Array<Hash>] get(/grids/:grid/nodes)[nodes] => [ { ... } ]
    def show_grid_health(grid, nodes)
      status = check_grid_health(grid, nodes)

      if status[:created] < status[:minimum]
        log_error "Grid only has #{status[:created]} of #{status[:initial]} initial nodes created, and requires at least #{status[:minimum]} nodes to operate"

      elsif status[:connected] < status[:minimum]
        log_error "Grid only has #{status[:connected]} of #{status[:initial]} initial nodes connected, and requires at least #{status[:minimum]} nodes to operate"

      elsif status[:created] < status[:initial]
        warning "Grid only has #{status[:created]} of #{status[:initial]} initial nodes created, and requires at least #{status[:minimum]} nodes to operate"

      elsif status[:connected] < status[:initial]
        warning "Grid only has #{status[:connected]} of #{status[:initial]} initial nodes connected, and requires at least #{status[:minimum]} nodes to operate"

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
  end
end
