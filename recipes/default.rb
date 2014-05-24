file "/etc/config.json" do
  content json_pretty(node[:cookbook][:config])
end
