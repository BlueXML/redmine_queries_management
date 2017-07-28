# RedMine Queries Management
## A RedMine plugin

This plugin is a plugin that aim to make easier the management of Custom Queries.
It provides the possibility to create Directories to store your queries.
Private directories are manageable by every users, public directories are manageable only for authorized users.

## Features :

This plugin provides the following features :
* Possibility to create/rename/delete query directories
* Public directories are shared (as well as custom queries) and are manageable only via permissions

Languages availables :
* EN
* FR

## Use :

To create folder :
	Projects -> All Issues -> add directory
To move issue to folder :
	Click on issue -> select folder

## Installation :

	$cd /path/to/redmine/directory/plugins
	$git clone https://github.com/BlueXML/redmine_queries_management.git
	$bundle exec rake redmine:plugins:migrate RAILS_ENV=production

## Compatibility :
Tested for RedMine 3.3.* (Manually)

## License :
This plugin is licensed under the GNU/GPL license v3.




