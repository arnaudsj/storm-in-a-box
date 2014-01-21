storm-in-a-box
==============

Vagrant + Chef recipes to bootstrap a single-node storm cluster in one command

## Requirements

* VirtualBox
* Vagrant
* bundler

## Installation

	git submodule init
	git submodule update
	bundle
	bundle exec vagrant up

Then simply visit http://localhost:8080/ on your machine to see the Storm UI page.

Please note that this was greatly inspired from RedStorm Vagrantfile (https://github.com/colinsurprenant/redstorm) and other published Storm cookbooks but not actively maintained.

## Next

* Include storm-starter with tutorial to submit basic topologies to local single-node-cluster using public data spouts.
* Design a multi-node cluster Vagrantfile for local provisioning.
* Expand to AWS provider to deploy on the fly Storm clusters on EC2.
