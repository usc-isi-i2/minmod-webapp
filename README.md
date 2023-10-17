## minmod-webapp

Currently running on [https://minmod.isi.edu/](https://minmod.isi.edu/) with [Apache Tomcat](https://tomcat.apache.org/) via [LodView](https://github.com/LodLive/LodView).

### Webapp deployment:
Change directory to path:
```commandline
cd /var/local/mindmod/
```
Deploy Apache Jena Fuseki to run a designated SPARQL endpoint (use `screen`:
```commandline
cd apache-jena-fuseki-4.9.0/
./fuseki-server --file <path_to_ttl> /minmod
```
Deploy Apache Tomcat (wraps this app) to run this app:
```commandline
cd cd apache-tomcat-7.0.109/
./bin/startup.sh
```
Make sure NGINX (web server) is running:
```commandline
systemctl start nginx
```
