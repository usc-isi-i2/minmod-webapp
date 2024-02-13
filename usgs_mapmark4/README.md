### Deployment Steps

Build docker

```
sudo docker build -t minmod-usgs-app .
```

Run docker container

```
sudo docker run --rm -d -p 3838:3838 minmod-usgs-app
```
