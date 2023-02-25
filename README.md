This is the docker version to *migrate* your osTicket to Docker.

- `update.sh` grabs the latest version of osTicket from Github
- `Dockerfile` builds a new Docker using Apache
- `docker-compose` uses nginx-proxy.

If you want to start a new osTicket, make sure you temporarily avoid the removing of the setup-dir in `update.sh`. Also avoid the copy of `ost-config.php`, but do check the info you need to add in. After installation copy the generated file.

To update:
- run `update.sh`. Check for errors.
- run docker-compose up -d --build
- wait, as this takes several minutes

This docker is used in production. I'm sharing these files, so I can learn while helping others. This means that e.g. nginx-proxy will remain the default, but I'm totally open to make overrides for other proxies.

For first use, remove info.txt, else it wil be "up-to-date". Also add your old SALT into `ost-config.php`.


Then navigate to http://localhost to complete teh setup

for the database connection setting from on the browser, go to the docker-compose file :
environment section.


DATABASE CONNECTION ERROR WHEN INSTALLING ON YOUR WEB BROWSER
Just replace the md5 hash number i.e 62c58f5fb82142653be0bfd625da584a 
with what you have in 'build\include\upgrader\streams\core.sig'
And that is all

