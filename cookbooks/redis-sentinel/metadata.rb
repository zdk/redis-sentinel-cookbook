name              'redis-sentinel'
version           '0.1.0'
maintainer        'Warachet Samtalee'
maintainer_email  'di@omise.co'
license           'MIT'
description       'Installs and configures Redis and Sentinel'

recipe 'redis-sentinel::default', 'Installs Redis and Sentinel'
recipe 'redis-sentinel::redis', 'Installs and configures Redis only'
recipe 'redis-sentinel::sentinel', 'Installs and configures Sentinel only'

depends 'build-essential'
