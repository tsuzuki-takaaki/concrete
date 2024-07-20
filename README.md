```sh
$ docker build --platform linux/amd64 -t concrete .
$ docker run --platform linux/amd64 -p 4567:4567 --rm -it --name concrete concrete
```
