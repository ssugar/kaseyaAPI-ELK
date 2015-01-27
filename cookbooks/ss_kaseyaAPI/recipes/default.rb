#
# Cookbook Name:: ss_kaseyaAPI
# Recipe:: default
#

execute "install suds" do
  command "pip install suds"
end

directory "/home/vagrant/kaseyaAPI" do
  action :create
end

cookbook_file "/home/vagrant/kaseyaAPI/getData.py" do
  source "getData.py"
end

cookbook_file "/var/log/logstash/getKaseyaData.json" do
  source "getData.json"
  mode "0777"
  owner "logstash"
  group "logstash"
end

cookbook_file "/etc/logstash/conf.d/logstash.conf" do
  source "logstash.conf"
end

execute "restart_logstash" do
  command "service logstash restart"
end

cookbook_file "/var/www/nginx-default/kibana/app/dashboards/kaseyadashboard.json" do
  source "kaseyadashboard.json"
end

cron "kaseya_api" do
  action :create
  hour "22,10"
  command "python /home/vagrant/kaseyaAPI/getData.py >> /var/log/logstash/getKaseyaData.json"
end

