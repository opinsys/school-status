# Log storage for various events in LTSP systems

# Installation

Get MongoDB 2.2.x

http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

    echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    apt-get update
    apt-get install mongodb-10gen


Get Node.js 0.8.x

http://nodejs.org/download/

Binary speed for the lazy

    wget http://nodejs.org/dist/v0.8.9/node-v0.8.9-linux-x64.tar.gz
    tar xzvf node-v0.8.9-linux-x64.tar.gz
    cd node-v0.8.9-linux-x64/
    cp -r * /usr/local

Install and build production scripts

    make

Start it

    npm start
