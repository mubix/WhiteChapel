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


## Installation::

* git clone https://github.com/mubix/WhiteChapel.git
* cd WhiteChapel
* bundle install

## Execution::

* ruby app.rb

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

## I don't know what to call this section yet

*
* https://github.com/shurizzle/ruby-fifo
** For the FIFO ruby GEM