require 'json'

Puppet::Type.type(:st2_pack).provide(:default) do
    desc "Provides support for managing st2 packs"

    commands :st2 => "/usr/bin/st2"

    def list_installed_packs
        token = st2_authenticate
        output = exec_st2('pack', 'list', '-a', 'name', '-j', '-t', token)
        parse_output_json(output)
    end

    # Get admin token
    def st2_authenticate
        # Reuse previous token
        if @token
            return @token
        else
            @token = exec_st2('auth', resource[:user], '-t', '-p', resource[:password]).chomp
        end
    end

    def create
        token = st2_authenticate
        if @resource[:source]
            source = @resource[:source]
        else
            source = @resource[:name]
        end
        exec_st2('pack', 'install', '-t', token, source)
    end

    def destroy
        token = st2_authenticate
        exec_st2('pack', 'remove', '-t', token, @resource[:name])
    end

    def exists?
        list_installed_packs.include?(@resource[:name])
    end

    # Return list of package names
    def parse_output_json(raw)
        result = []
        my_hash = JSON.parse(raw)
        my_hash.each do |pack|
            result << pack['name']
        end
        debug("Installed packs: #{result}")
        result
    end

    private

    # execute the st2 command and use the system locale (UTF8)
    # so that the st2 CLI doesn't complain and throw errors
    def exec_st2(*args)
      Puppet::Util::Execution.execute([command(:st2)] + args,
                                      {:override_locale => false})
    end
end
