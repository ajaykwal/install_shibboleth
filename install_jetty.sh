# run this script from a user with sudo permission e.g. azureuser

#first check java and install if necessary

if `java -version` ; then
	echo "java is present"
else
	echo "installing java ..."
	sudo yum install -y java-1.8.0-openjdk
	sudo sh -c "echo export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64 >> /etc/profile"
fi
source /etc/profile
env|grep JAVA_HOME

# second check jetty user
if getent passwd jetty > /dev/null 2>&1; then
	echo "jetty user eixsts"
else
	echo "jetty user does not exists"
	sudo useradd jetty
fi

#not check if jetty is installed 

if [ -f "/etc/init.d/jetty" ]
then
    echo "jetty exists."
else
    echo "installing jetty.."
    echo "- downloading jetty tar into tmp"
    wget -P /tmp "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.18.v20190429/jetty-distribution-9.4.18.v20190429.tar.gz"
    echo "- now extracting in opt"
    sudo tar zxvf /tmp/jetty-distribution-9.4.18.v20190429.tar.gz -C /opt/
    echo "- now creating a softlink to opt jetty"
    sudo ln -s "/opt/jetty-distribution-9.4.18.v20190429/" /opt/jetty
    echo "- now setting ownership to jetty user"
    sudo chown -R jetty:jetty /opt/jetty/
    sudo mkdir /var/run/jetty
    sudo chown jetty:jetty /var/run/jetty
    sudo ln -s /opt/jetty/bin/jetty.sh /etc/init.d/jetty
    sudo chkconfig --add jetty
fi


# now configure jetty options 
    
if [ -f "/etc/default/jetty" ]
then
	echo "jetty options exists"
else
    echo "- now creating jetty options file etc default"
    echo "JETTY_HOME=/opt/jetty" | sudo tee /etc/default/jetty
    echo "JETTY_BASE=/opt/jetty/demo-base" | sudo tee -a /etc/default/jetty
    echo "JETTY_USER=jetty" | sudo tee -a /etc/default/jetty
fi

sudo service jetty start
