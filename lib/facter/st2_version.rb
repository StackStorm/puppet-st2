Facter.add(:st2_version) do
  setcode do
    if Facter::Core::Execution.which('st2')
      st2_version = Facter::Core::Execution.execute('st2 --version 2>&1')
      %r{^st2?\s+([\w\.]+)}.match(st2_version)[1]
    end
  end
end
