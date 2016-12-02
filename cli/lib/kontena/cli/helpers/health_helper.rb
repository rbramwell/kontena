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
  end
end
