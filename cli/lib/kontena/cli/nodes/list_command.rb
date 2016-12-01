module Kontena::Cli::Nodes
  class ListCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    option ["--all"], :flag, "List nodes for all grids", default: false

    def execute
      require_api_url
      require_current_grid
      token = require_token

      if all?
        grids = client(token).get("grids")
        puts "%-70s %-10s %-40s" % [ 'Name', 'Status', 'Labels']

        grids['grids'].each do |grid|
          nodes = client(token).get("grids/#{grid['name']}/nodes")
          nodes['nodes'].each do |node|
            if node['connected']
              status = 'online'
            else
              status = 'offline'
            end
            puts "%-70.70s %-10s %-40s" % [
              "#{grid['name']}/#{node['name']}",
              status,
              (node['labels'] || ['-']).join(",")
            ]
          end
        end
      else
        grid = client(token).get("grids/#{current_grid}")
        nodes = client(token).get("grids/#{current_grid}/nodes")
        puts "%-70s %-10s %-10s %-40s" % ['Name', 'Status', 'Initial', 'Labels']
        nodes = nodes['nodes'].sort_by{|n| n['node_number'] }
        initial_nodes_created = 0
        initial_nodes_connected = 0
        nodes.each do |node|
          initial_nodes_created += 1 if node['initial_member']
          initial_nodes_connected += 1 if node['initial_member'] && node['connected']
          puts "%-70.70s %-10s %-10s %-40s" % [
            node['name'],
            node['connected'] ? 'online' : 'offline',
            node['initial_member'] ? 'yes' : 'no',
            (node['labels'] || ['-']).join(",")
          ]
        end

        # validate initial nodes for etcd quorum
        initial_nodes = grid['initial_size']
        minimum_nodes = (grid['initial_size'] * 0.5).ceil # a majority

        if initial_nodes_created < minimum_nodes
          error "Grid only has #{initial_nodes_created} of #{grid['initial_size']} initial nodes created, and requires at least #{minimum_nodes} nodes to operate"

        elsif initial_nodes_connected < minimum_nodes
          error "Grid only has #{initial_nodes_connected} of #{grid['initial_size']} initial nodes connected, and requires at least #{minimum_nodes} nodes to operate"

        elsif initial_nodes_created < initial_nodes
          warning "Grid only has #{initial_nodes_created} of #{grid['initial_size']} initial nodes created, and requires at least #{minimum_nodes} nodes to operate"

        elsif initial_nodes_connected < initial_nodes
          warning "Grid only has #{initial_nodes_connected} of #{grid['initial_size']} initial nodes connected, and requires at least #{minimum_nodes} nodes to operate"

        end
      end
    end
  end
end
