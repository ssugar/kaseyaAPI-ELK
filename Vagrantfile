# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

#script to set everything up. chef is slow to download now while the AAG line is cut so only using vagrant provisioners to speed development up
$script = <<SCRIPT
sudo su
echo "deb http://mirror-fpt-telecom.fpt.net/ubuntu/ precise main restricted universe" > /etc/apt/sources.list
echo "deb http://mirror-fpt-telecom.fpt.net/ubuntu/ precise-updates main restricted universe" >> /etc/apt/sources.list
echo "deb http://mirror-fpt-telecom.fpt.net/ubuntu/ precise-security main restricted universe" >> /etc/apt/sources.list
echo "Asia/Ho_Chi_Minh" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
apt-get update
apt-get install curl -y
apt-get install nano -y
apt-get install nginx -y
apt-get install openjdk-7-jdk -y
cd /home/vagrant
dpkg -i elasticsearch-1.4.2.deb
update-rc.d elasticsearch defaults 95 10
cp /home/vagrant/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
service elasticsearch start
dpkg -i logstash-1.4.2-1.deb
service logstash restart
tar -xvzf kibana-latest.tar.gz
cp -R kibana-latest /usr/share/nginx/www/kibana
SCRIPT

$script2 = <<SCRIPT
cp /home/vagrant/logstash.conf /etc/logstash/conf.d/logstash.conf
cp /home/vagrant/kaseyadashboard.json /usr/share/nginx/www/kibana/app/dashboards/default.json
cp /home/vagrant/drayteksyslog.json /usr/share/nginx/www/kibana/app/dashboards/drayteksyslog.json
cd /home/vagrant
service nginx restart
service logstash restart
type -a curl
curl -4 -v -XGET http://localhost:9200
SCRIPT

$script3 = <<SCRIPT
curl -O https://bootstrap.pypa.io/ez_setup.py
python ez_setup.py
easy_install pip
apt-get install python-pycurl -y
pip install xmltodict
pip install suds
cp /home/vagrant/getData.json /var/log/logstash/getKaseyaData.json
chmod 777 /var/log/logstash/getKaseyaData.json
chown logstash:logstash /var/log/logstash/getKaseyaData.json
crontab -l | { cat; echo "0 0 * * * python /home/vagrant/sendData.py > /var/log/logstash/getKaseyaData.json"; } | crontab -   
SCRIPT


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
   #Set the virtual machine 'box' to use
   config.vm.box = "hashicorp/precise64"
   #Set the vm name
   config.vm.define :kaseyaELK do |t|
   end

   config.vm.provider :hyperv do |v|
	 v.vmname = "kaseyaELK"
     v.memory = 2048
	 v.cpus = 4
   end
   
   #copy the ELK installer files locally to save time
   config.vm.provision "file", source: "./localELK/elasticsearch-1.4.2.deb", destination: "/home/vagrant/elasticsearch-1.4.2.deb"
   config.vm.provision "file", source: "./cookbooks/ss_kibana/files/default/elasticsearch.yml", destination: "/home/vagrant/elasticsearch.yml"
   config.vm.provision "file", source: "./localELK/logstash-1.4.2-1.deb", destination: "/home/vagrant/logstash-1.4.2-1.deb"
   config.vm.provision "file", source: "./localELK/kibana-latest.tar.gz", destination: "/home/vagrant/kibana-latest.tar.gz"
   config.vm.provision "file", source: "./cookbooks/ss_softflowd/files/default/softflowd.conf", destination: "/home/vagrant/softflowd"   
   
   #run the script above
   config.vm.provision "shell", inline: $script

   #copy a few config files into their place post install
   config.vm.provision "file", source: "./cookbooks/ss_kaseyaAPI/files/default/logstash.conf", destination: "/home/vagrant/logstash.conf"
   config.vm.provision "file", source: "./cookbooks/ss_kibana/files/default/netflow.json", destination: "/home/vagrant/netflow.json"
   config.vm.provision "file", source: "./cookbooks/ss_kibana/files/default/drayteksyslog.json", destination: "/home/vagrant/drayteksyslog.json"
   config.vm.provision "file", source: "./cookbooks/ss_kaseyaAPI/files/default/getData.py", destination: "/home/vagrant/getData.py"
   config.vm.provision "file", source: "./cookbooks/ss_kaseyaAPI/files/default/getData.json", destination: "/home/vagrant/getData.json"
   config.vm.provision "file", source: "./cookbooks/ss_kaseyaAPI/files/default/kaseyadashboard.json", destination: "/home/vagrant/kaseyadashboard.json"
   config.vm.provision "file", source: "./username.txt", destination: "/home/vagrant/username.txt"
   config.vm.provision "file", source: "./password.txt", destination: "/home/vagrant/password.txt"

   #restart the services we just replaced configs for and attempts to set some mappings for elasticsearch.
   config.vm.provision "shell", inline: $script2
   
   config.vm.provision "shell", path: "updatedEsMappings.sh"

   config.vm.provision "shell", inline: $script3

end
