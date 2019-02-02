require 'json'
require 'shellwords'

Puppet::Type.type(:st2_pack).provide(:default) do
  desc 'Provides support for managing st2 packs'

  commands st2: '/usr/bin/st2'

  # Get admin token
  def st2_authenticate
    # Reuse previous token
    return @token if @token
    @token = exec_st2('auth', resource[:user], '-t', '-p', resource[:password]).chomp
  end

  def create
    token = st2_authenticate
    source = (@resource[:source]) ? @resource[:source] : @resource[:name]
    exec_st2('pack', 'install', '-t', token, source)
  end

  def destroy
    token = st2_authenticate
    exec_st2('pack', 'remove', '-t', token, @resource[:name])
  end

  def exists?
    list_installed_packs.include?(@resource[:name])
  end

  def list_installed_packs
    token = st2_authenticate
    output = exec_st2('pack', 'list', '-a', 'name', '-j', '-t', token)
    parse_output_json(output)
  end

  # Return list of package names
  def parse_output_json(raw)
    result = []
    if raw && !raw.empty?
      pack_list = JSON.parse(raw)
      result = pack_list.map { |pack| pack['name'] }
      debug("Installed packs: #{result}")
    end
    result
  end

  private

  # execute the st2 command and use the system locale (UTF8)
  # so that the st2 CLI doesn't complain and throw errors
  def exec_st2(*args)
    # escape all arguments so they're safe to use in a shell command
    escaped_args = args.map { |a| Shellwords.shellescape(a) }
    Puppet::Util::Execution.execute([command(:st2)] + escaped_args,
                                    override_locale: false)
  end
end
