
role :web, "node001.ext.alwlabs.com"
role :db,  "node001.ext.alwlabs.com"
role :app, "node001.ext.alwlabs.com", :primary => true

set   :env, "staging"

set   :branch, 'master'

