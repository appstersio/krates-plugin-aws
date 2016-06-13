module Kontena::Plugin::Aws::Nodes
  class CreateCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    parameter "[NAME]", "Node name"
    option "--access-key", "ACCESS_KEY", "AWS access key ID", required: true
    option "--secret-key", "SECRET_KEY", "AWS secret key", required: true
    option "--key-pair", "KEY_PAIR", "EC2 Key Pair", required: true
    option "--region", "REGION", "EC2 Region", default: 'eu-west-1'
    option "--zone", "ZONE", "EC2 Availability Zone", default: 'a'
    option "--vpc-id", "VPC ID", "Virtual Private Cloud (VPC) ID (default: default vpc)"
    option "--subnet-id", "SUBNET ID", "VPC option to specify subnet to launch instance into (default: first subnet in vpc/az)"
    option "--type", "SIZE", "Instance type", default: 't2.small'
    option "--storage", "STORAGE", "Storage size (GiB)", default: '30'
    option "--version", "VERSION", "Define installed Kontena version", default: 'latest'
    option "--associate-public-ip-address", :flag, "Whether to associated public IP in case the VPC defaults to not doing it", default: false, attribute_name: :associate_public_ip
    option "--security-groups", "SECURITY GROUPS", "Comma separated list of security groups (names) where the new instance will be attached (default: create grid specific group if not already existing)"

    def execute
      require_api_url
      require_current_grid

      require 'kontena/machine/aws'
      grid = grid(current_grid)
      provisioner = provisioner(client(require_token), access_key, secret_key, region)
      provisioner.run!(
          master_uri: api_url,
          grid_token: grid['token'],
          grid: current_grid,
          name: name,
          type: type,
          vpc: vpc_id,
          zone: zone,
          subnet: subnet_id,
          storage: storage,
          version: version,
          key_pair: key_pair,
          associate_public_ip: associate_public_ip?,
          security_groups: security_groups
      )
    end

    # @param [String] id
    # @return [Hash]
    def grid(id)
      client(require_token).get("grids/#{id}")
    end

    # @param [Kontena::Client] client
    # @param [String] access_key
    # @param [String] secret_key
    # @param [String] region
    # @return [Kontena::Machine::Aws::NodeProvisioner]
    def provisioner(client, access_key, secret_key, region)
      Kontena::Machine::Aws::NodeProvisioner.new(client, access_key, secret_key, region)
    end
  end
end