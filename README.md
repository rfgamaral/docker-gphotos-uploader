# rfgamaral/gphotos-uploader

![docker build](https://img.shields.io/docker/build/rfgamaral/gphotos-uploader.svg)
![docker build](https://img.shields.io/docker/automated/rfgamaral/gphotos-uploader.svg)
![image size](https://img.shields.io/microbadger/image-size/rfgamaral/gphotos-uploader.svg)
![layers](https://img.shields.io/microbadger/layers/rfgamaral/gphotos-uploader.svg)
![docker pulls](https://img.shields.io/docker/pulls/rfgamaral/gphotos-uploader.svg)
![docker Stars](https://img.shields.io/docker/stars/rfgamaral/gphotos-uploader.svg)

This repository contains the _Dockerfiles_ and all other files needed to create and run a container with a background task to mass upload media folders to your [Google Photos](https://photos.google.com) account. The task runs periodically on a predefined schedule and is powered by [`gphotos-uploader-cli`](https://github.com/nmrshll/gphotos-uploader-cli).

## Usage

### Create and start the container

Make sure the Docker daemon is running and then start the container like this:

```
docker run -d \
    --name=gphotos-uploader \
    -v {PATH_TO_CONFIGURATION}:/config \
    -v {PATH_TO_PHOTOS_LIBRARY}:/photos \
    --restart unless-stopped \
    rfgamaral/gphotos-uploader
```

The `gphotos-uploader-cli` tool will automatically run in the background every 8 hours by default. Also, don't forget to replace `{PATH_TO_CONFIGURATION}` and `{PATH_TO_PHOTOS_LIBRARY}` with your host machine absolute paths.

Please check the documentation below for more detailed information on all the configuration parameters.

### Container configuration parameters

Container images are configured using parameters passed at run-time (such as those above). Some of these parameters are separated by a colon and indicate `<external>:<internal>` respectively.

| Parameter | Description |
| :----: | --- |
| `-e GPU_SCHEDULE="0 */8 * * *"` | Background task schedule expression (see [crontab.guru](https://crontab.guru/)). |
| `-v {PATH_TO_CONFIGURATION}:/config` | Absolute host path to store `gphotos-uploader-cli` configuration. |
| `-v {PATH_TO_PHOTOS_LIBRARY}:/photos` | Absolute host path for the photos library source folder. |

## Support

### Force run `gphotos-uploader-cli` upload task

```
docker exec -it gphotos-uploader gphotos-uploader-cli
```

### Shell access whilst the container is running

```
docker exec -it gphotos-uploader /bin/sh
```

### To monitor the logs of the container in real-time

```
docker logs -f gphotos-uploader
```

## License

Use of this source code is governed by an MIT-style license that can be found in the [LICENSE](LICENSE) file.
