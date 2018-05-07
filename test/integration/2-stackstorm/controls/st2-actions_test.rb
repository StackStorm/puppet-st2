# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'st2-actions' do
  title 'Ensure st2 actions are working'
  desc '
    Check that st2 run and st2 pack commands are executing successfully.
  '

  describe command("st2 pack install st2") do
    its(:exit_status) { is_expected.to eq 0 }
  end

  # Sudo really works
  describe command("st2 run core.local_sudo id") do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { should match /root/ }
  end

  # Check that UTF-8 locale is passed through
  describe command("st2 run core.local cmd=locale") do
    its(:stdout) { should match /UTF-8/ }
  end

  # Check that 'st2 run' can handle unicode in action params
  command("st2 run core.local cmd=\"echo '¯\_(ツ)_/¯'\"") do
    its(:exit_status) { is_expected.to eq 0 }
  end
end
