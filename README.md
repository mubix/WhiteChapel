# White Chapel Password Auditing Framework

This project is meant to be run internally, since I haven't
really seen any open source projects that do all the things
I think a password auditing framework should do I'm creating
my own. Here are the features that I intend to have:
(Please feel free to create bug reports or feature requests
outside of the items stipulated here)

1. Search for hashes quickly
2. Upload password dumps for cracking hashes
3. Upload hash lists for cracking
4. Generate hash tables for all popular hash types based on
searched password, uploaded dictionaries, and cracked hashes

## Pre-Installation

### Elastic Search

WhiteChapel requires you to have ElasticSearch running.

You can download it here: http://www.elasticsearch.org/download/

Once you have it downloaded, if you are using the tar, just 'cd'
into the bin directory and do a ```./elasticsearch -f ``` to start
elastic search up.

Elastic Search doesn't have to run on the same machine as you
are running WhiteChapel. Just make a config file called 'elastic.conf'
copying the exmaple provided (elastic-example.conf) with the URL.
Usually ```http://127.0.0.1:9200/``` if you are running ES locally.

Elastic Search has custering built into it and running another
elastic search server on another system in the same broadcast area
will automatically join the cluster and decrease the load.

### Redis Server for Queue management

You can download it here: http://redis.io/download

Most package managers (apt-get/yum/OSX ports/brew) have redis server
as a package and it's really easy to get set up. There is also
as Redis IP/PORT configuation in the Rakefile if you want to run
Redis on another server.

This makes it seemless to upload dictionaries worth
of passwords and have the server not flinch at 100MB files
(obviously the upload might take a minute but the DB will
process it VERY fast)

You can have more than one queue (redis) server if you want
as pretty much every action is compartmentalized.


## Installation::

* git clone https://github.com/mubix/WhiteChapel.git
* cd WhiteChapel
* bundle install

### Starting workers

You can start additional "workers" to handle the password
import processing (usually only an issue when importing be wordlists)
by issusing the following command
```
TERM_CHILD=1 QUEUE='*' rake resque:work
```
from inside the WhiteChapel directory.

## Execution::

* foreman start


## Importing Dictionaries from the Command Line

For most cases file upload via the web interface is adding
a hurdle (HTTP upload) that doesn't need to be there. So
running the ruby file "dictionaryimport_cli.rb" from whithin
the WhiteChapel directory will directly import the wordlist into
the password processing queue.
```
./dictionaryimport_cli.rb /path/to/wordlist/rockyou.txt
```
Should simply output how many lines it imported when it's done.

## Todo List::

* See the file: todo.list or Github issues

## Notes::

It's all kinds of fun using a ton of different tools
to crack passwords, and then having to sort and go through
and maintain or delete them... right?

This project will hopefully be a very modular front
end to cracking passwords. The idea is you tell it a tool
to use and how to use it, and what to expect in results.
The the overlying framework should swallow that up
and allow you to upload / crack and manage passwords,
hashs, and dictionary collections. Allowing you to
look back historically at what was cracked, and with
what tool, resend a group through the engines again
have as many engines as you want etc... Giving you
more time to concentrate on using the passwords instead
of figuring out the tools to break them.

If I can keep the idea as scalable as possible, I
think it would fit really well plugged into any
pentester/red teamer/ or firm's toolkit

::crossed fingers::

Also, I picked the name based on where Jack the Ripper
was performing his murders... seems a bit dark now
that I think about it, but oh well...

## Blame Section

* Twitter Bootstrap
  * For the prettifying of the interface
  * http://twitter.github.com/bootstrap/
  * Used https://github.com/pokle/sinatra-bootstrap for Sinatra
* Jasny Bootstrap
  * Specifically used to pretty up the upload dialog since TB doesn't
* MySQL hash generation
  * https://gist.github.com/1290541
* Change SublimeText 2 to use RVM instead of system ruby
  * http://rubenlaguna.com/wp/2012/12/07/sublime-text-2-rvm-rspec-take-2/
