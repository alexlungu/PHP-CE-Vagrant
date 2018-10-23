# Empty repo for the "Event Sourcing For Real" workshop at PHP CE

## Getting started
- Clone this repository and `cd` into it.
- Run `vagrant up`.
- Once the box is up and running, type `vagrant ssh`
- Run `composer install`. This will install PHPUnit test suite

## Database
The box comes preloaded with mysql 5.7 and a development schema is created by default. The default credentials are `root` and `password`

## Running tests
As part of the boot up process, the vagrant box already has a phpunit alias set up.
If you're not using PHPStorm or if it's not already configure to right click and run tests automatically from the class, you can run the tests from the terminal:
1. Running all tests
`cd Tests/ && phpunit TestExample`
2. Running a single test
`cd Tests/ && phpunit --filter testEmpty TestExample`