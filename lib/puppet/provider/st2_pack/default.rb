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

  def auth_params
    if @resource[:apikey]
      ['--api-key', @resource[:apikey]]
    else
      ['-t', st2_authenticate]
    end
  end

  def create
    source = (@resource[:source]) ? @resource[:source] : @resource[:name]
    if @resource[:version]
      source = "#{source}=#{@resource[:version]}"
    end
    exec_st2('pack', 'install', source, *auth_params)
  end

  def destroy
    exec_st2('pack', 'remove', @resource[:name], *auth_params)
  end

  def exists?
    if @resource[:version]
      list_installed_packs_with_versions.include?([@resource[:name], @resource[:version]])
    else
      list_installed_packs.include?(@resource[:name])
    end
  end

  def list_installed_packs
    output = exec_st2('pack', 'list', '-a', 'ref', '-j', *auth_params)
    parse_output_json(output)
  end

  def list_installed_packs_with_versions
    output = exec_st2('pack', 'list', '-a', 'ref', 'version', '-j', *auth_params)
    parse_version_output_json(output)
  end

  # Return list of package names
  def parse_output_json(raw)
    result = []
    if raw && !raw.empty?
      pack_list = JSON.parse(raw)
      result = pack_list.map { |pack| pack['ref'] }
      debug("Installed packs: #{result}")
    end
    result
  end

  # Return list of package names
  def parse_version_output_json(raw)
    result = []
    if raw && !raw.empty?
      pack_list = JSON.parse(raw)
      result = pack_list.map { |pack| [pack['ref'], pack['version']] }
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

    # when passing in a command array into Puppet::Util::Execution.execute()
    # it doesn't do shell expansion on the arguments, but special characters are still
    # sometimes not processed correctly by the underlying system.
    # instead if you specify the first argument as a string, the command is treated
    # as a shell command with normal shell expansion rules and our escaping above
    # works correctly
    # see: https://ruby-doc.org/core/Kernel.html#method-i-exec
    command_str = ([command(:st2)] + escaped_args).join(' ')

    # when we started passing in the override_locale: option, there is some "known behavior"
    # of this function where when any option is passed in it sets failonfail: false and
    # combine: false for some terrible reason. We want both of those set to true like
    # they are when no options are specified, so we set them explicitly.
    # note: We are forcing en_US.UTF-8 under the hood here so we have a consistent
    #       locale set that is expected by StackStorm. This does NOT affect the user.
    Puppet::Util::Execution.execute(command_str,
                                    override_locale: false,
                                    failonfail: true,
                                    combine: true,
                                    custom_environment: {
                                      'LANG' => 'en_US.UTF-8',
                                      'LC_ALL' => 'en_US.UTF-8',
                                    })
  end
end
