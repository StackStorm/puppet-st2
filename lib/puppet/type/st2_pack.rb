Puppet::Type.newtype(:st2_pack) do
  @doc = 'Manage st2 packs'

  ensurable

  newparam(:name) do
    desc 'Name of the pack.'
    isnamevar
  end

  newparam(:user) do
    desc 'St2 cli user'
  end

  newparam(:password) do
    desc 'St2 cli password'
  end

  newparam(:apikey) do
    desc 'St2 apikey'
  end

  newparam(:version) do
    desc 'Specific pack version to install'
  end

  newparam(:source) do
    desc 'Git URL for st2 pack'
  end
end
