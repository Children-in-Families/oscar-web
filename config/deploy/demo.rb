set :stage, 'demo'
server 'cif-web-demo.rotati.com', user: 'deployer', roles: %w{app web db}
