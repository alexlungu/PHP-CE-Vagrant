# Empty repo for the "Event Sourcing For Real" workshop at PHP CE

## Getting started
- Clone this repository and `cd` into it.
- Run `vagrant up`.
- Once the box is up and running, type `vagrant ssh`
- Run `composer install`. This will install PHPUnit test suite

## Running tests
As part of the boot up process, the vagrant box already has a phpunit alias set up.
To run tests from the command line `cd Tests` and run `phpunit xxxTestName`