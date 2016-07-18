# Mapserver in Docker

[![](https://imagelayers.io/badge/geodata/mapserver:latest.svg)](https://imagelayers.io/?images=geodata/mapserver:latest)

This is an Ubuntu derived image containing
[MapServer](http://www.mapserver.org/) running under the Nginx web server as a
FastCGI service.  Mapserver is compiled with a broad range of options, including
a comprehensive version of GDAL.

Each branch in the git repository corresponds to a supported Map server version
(e.g. `7.0.1`) with the master branch following MapServer master. These branch
names are reflected in the image tags on the Docker Hub.

## Usage

The HTTP endpoint for the MapServer `mapserv` CGI binary is the root URL at
`/`. This can be tested by mapping the web server's port `80` on the container
to port `8080` on the host:

    docker run -p 8080:80 geodata/mapserver

You can then test using the included example mapfile by pointing your browser at
<http://localhost:8080/?map=/usr/local/share/mapserver/examples/test.map&mode=map>.
    
Other than the test mapfile located at
`/usr/local/share/mapserver/examples/test.map` no other MapServer configuration
is provided: you will need to provide appropriate mapfiles and ancilliary
configuration files (e.g. templates) for running Mapserver, either via volume or
bind mounts or in a derived image.  E.g. assuming you have the mapfile
'my-app.map' in the current working directory, you could mount it as:

    docker run -v $(pwd):/maps:ro -p 8080:80 geodata/mapserver

You will then be able to access the map from your host machine at
<http://localhost:8080/?map=/maps/my-app.map&mode=map>.
