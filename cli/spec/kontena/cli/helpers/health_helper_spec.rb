require "kontena/cli/helpers/health_helper"

describe Kontena::Cli::Helpers::HealthHelper do
  let :klass do
    Class.new do
      include Kontena::Cli::Helpers::HealthHelper
    end
  end

  subject { klass.new }

  context "For a initial_size=1 grid" do
    let :grid do
      {
        "id" => "test",
        "name" => "test",
        "initial_size" => 1,
        "node_count" => 1,
      }
    end

    context "with a single offline node" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => false,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "shows an error" do
          expect(subject).to_not receive(:warning)
          expect(subject).to receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end

    context "with a single online node" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "does not show any warning or error" do
          expect(subject).to_not receive(:warning)
          expect(subject).to_not receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end
  end

  context "For a initial_size=2 grid" do
    let :grid do
      {
        "id" => "test",
        "name" => "test",
        "initial_size" => 2,
        "node_count" => 1,
      }
    end

    context "with a single online node" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "shows an error" do
          expect(subject).to_not receive(:warning)
          expect(subject).to receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end

    context "with two online nodes" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
          {
            "connected" => true,
            "name" => "node-2",
            "node_number" => 2,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "does not show any warning or error" do
          expect(subject).to_not receive(:warning)
          expect(subject).to_not receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end
  end

  context "For a initial_size=3 grid" do
    let :grid do
      {
        "id" => "test",
        "name" => "test",
        "initial_size" => 3,
        "node_count" => 1,
      }
    end

    context "with a single online node" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
          {
            "connected" => false,
            "name" => "node-2",
            "node_number" => 1,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "shows an error" do
          expect(subject).to_not receive(:warning)
          expect(subject).to receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end

    context "with two online nodes" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
          {
            "connected" => true,
            "name" => "node-2",
            "node_number" => 2,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "shows an warning" do
          expect(subject).to receive(:warning)
          expect(subject).to_not receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end

    context "with two online nodes and one offline node" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
          {
            "connected" => true,
            "name" => "node-2",
            "node_number" => 2,
            "initial_member" => true,
          },
          {
            "connected" => false,
            "name" => "node-3",
            "node_number" => 3,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "shows an warning" do
          expect(subject).to receive(:warning)
          expect(subject).to_not receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end

    context "with two online initial nodes and one non-initial node" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
          {
            "connected" => true,
            "name" => "node-2",
            "node_number" => 2,
            "initial_member" => true,
          },
          {
            "connected" => true,
            "name" => "node-4",
            "node_number" => 4,
            "initial_member" => false,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "shows an warning" do
          expect(subject).to receive(:warning)
          expect(subject).to_not receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end

    context "with three online nodes" do
      let :grid_nodes do
        { "nodes" => [
          {
            "connected" => true,
            "name" => "node-1",
            "node_number" => 1,
            "initial_member" => true,
          },
          {
            "connected" => true,
            "name" => "node-2",
            "node_number" => 2,
            "initial_member" => true,
          },
          {
            "connected" => true,
            "name" => "node-3",
            "node_number" => 3,
            "initial_member" => true,
          },
        ] }
      end

      describe '#show_grid_health' do
        it "does not show any warning or error" do
          expect(subject).to_not receive(:warning)
          expect(subject).to_not receive(:log_error)

          subject.show_grid_health(grid, grid_nodes['nodes'])
        end
      end
    end
  end
end
