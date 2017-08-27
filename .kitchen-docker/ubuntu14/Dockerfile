FROM stackstorm/packagingtest:trusty-upstart

RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN sudo dpkg -i puppetlabs-release-trusty.deb
RUN sudo apt-get update
RUN sudo apt-get install puppet=3.8.7-1puppetlabs1
