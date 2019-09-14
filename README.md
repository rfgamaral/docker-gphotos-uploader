# rfgamaral/gphotos-uploader

![ci workflow](https://github.com/rfgamaral/docker-gphotos-uploader/workflows/Docker%20Images%20CI/badge.svg)
![image size](https://img.shields.io/microbadger/image-size/rfgamaral/gphotos-uploader.svg)
![layers](https://img.shields.io/microbadger/layers/rfgamaral/gphotos-uploader.svg)
![docker pulls](https://img.shields.io/docker/pulls/rfgamaral/gphotos-uploader.svg)
![docker Stars](https://img.shields.io/docker/stars/rfgamaral/gphotos-uploader.svg)

This repository contains the _Dockerfiles_ and all other files needed to create and run a container with a background task to mass upload media folders to your [Google Photos](https://photos.google.com) account. The task runs periodically on a predefined schedule and is powered by [`gphotos-uploader-cli`](https://github.com/nmrshll/gphotos-uploader-cli).

## Supported Architectures

This image supports multiple architectures such as `x86-64`, `arm64` and `armhf`. Simply pulling `rfgamaral/gphotos-uploader` should retrieve the correct image for your architecture, but you can always pull specific architecture images via tags.

The architectures supported by this image are:

| Architecture | Tag (`latest`) | Tag (`x.y.z`) | Tag (`preview`) |
| :----: | --- | --- | --- |
| x86-64 | `amd64-latest` | `amd64-x.y.z` | `amd64-preview` |
| arm64 | `arm64v8-latest` | `arm64v8-x.y.z` | `arm64v8-preview` |
| armhf | `arm32v7-latest` | `arm32v7-x.y.z` | `arm32v7-preview` |

## Usage

### Create and start the container

Make sure the Docker daemon is running and then start the container like this:

```
docker run -d \
    --name=gphotos-uploader \
    -e GPU_SCHEDULE="<SCHEDULE_EXPRESSION>" \
    -p <EXTERNAL_PORT>:29070 \
    -v <PATH_TO_CONFIGURATION>:/config \
    -v <PATH_TO_PHOTOS_LIBRARY>:/photos \
    --add-host host.docker.internal:<DOCKER_HOST_IP> \
    --restart unless-stopped \
    rfgamaral/gphotos-uploader
```

Once the container is running and before `gphotos-uploader-cli` is able to work properly, you'll first need to edit the `/config/config.hsjon` and set your `APIAppCredentials` according to the [Authentication](#authentication) section below. Please refer to the official [documentation](https://github.com/nmrshll/gphotos-uploader-cli/blob/master/.docs/configuration.md) for all other configuration options.

### Container configuration parameters

Please refer to the following table for all available configuration paramaters that can be passed at run-time to container images:

| Parameter | Required | Description |
| :----: | --- | --- |
| `-e GPU_SCHEDULE="<SCHEDULE_EXPRESSION>"` | | Background task schedule expression (defaults to every 8 hours).<br>See [crontab.guru](https://crontab.guru/) for help with the schedule expression. |
| `-p <EXTERNAL_PORT>:29070` | <div style="text-align: center">✔</div> | Publish the container's `29070` internal port to the host as `<EXTERNAL_PORT>`.<br>This is necessary for the Authentication process (more on that below). |
| `-v <PATH_TO_CONFIGURATION>:/config` | <div style="text-align: center">✔</div> | Absolute host path to store `gphotos-uploader-cli` configuration. |
| `-v <PATH_TO_PHOTOS_LIBRARY>:/photos` | <div style="text-align: center">✔</div> | Absolute host path for the photos library source folder. |
| `--add-host host.docker.internal:<DOCKER_HOST_IP>` |  | Map the Docker host IP to `host.docker.internal`.<br>This might be necessary for the Authentication process (more on that below). |

## Authentication

Given that `gphotos-uploader-cli` uses OAuth 2 to access Google APIs, authentication is a bit tricky and envolves a few manual steps. Please follow the guide below carefully, to give `gphotos-uploader-cli` the required access to your Google Photos account.

### API credentials

Before you can use `gphotos-uploader-cli`, you must enable the Photos Library API and request an OAuth 2.0 Client ID.

1. Make sure you're logged in into the Google Account where your photos should be uploaded to.
2. Start by [creating a new project](https://console.cloud.google.com/projectcreate) in Google Cloud Platform and give it a name (example: _Google Photos Uploader_).
3. Enable the [Google Photos Library API](https://console.cloud.google.com/apis/library/photoslibrary.googleapis.com) by clicking the <kbd>ENABLE</kbd> button.
4. Configure the [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent) by setting the application name (example: _docker-gphotos-uploader_), add `nip.io` as an **Authorized domain** and then click the <kbd>Save</kbd> button on the bottom.
5. Create [credentials](https://console.cloud.google.com/apis/credentials) by clicking the **Create credentials → OAuth client ID** option, then pick **Web application** as the application type, give it a name (example: _gphotos-uploader-cli_) and add `http://<DOCKER_HOST_IP>.nip.io:<EXTERNAL_PORT>` to both **Authorized JavaScript origins** and **Authorized redirect URIs**.
   - This OAuth client will only work if both `<DOCKER_HOST_IP>` and `<EXTERNAL_PORT>` match the ones being used by the Docker container. For instance, if your Docker host has the `192.168.0.123` network IP and you've passed `-p 12345:29070` to the `docker run` command, you would add `http://192.168.0.123.nip.io:12345`.
6. Copy the **Client ID** and the **Client Secret** and keep them ready to use in the next section.

### CLI authentication

Once an OAuth 2.0 Client ID is generated, authenticating `gphotos-uploader-cli` against your Google Account is required for proper access to your Google Photos account.

_The following steps assume the container has been created and it's running. If not, please refer to the [create and start the container](#create-and-start-the-container) section above before continuing._

1. Open the `/config/config.hsjon` file and set both the `ClientID` and `ClientSecret` options to the ones generated on the previous section and your the `jobs[0].account` option to the Google Account e-mail address where your photos should be uploaded to.
2. Open your favorite terminal and run the following command to start the authentication process:

    ```
    docker exec -it gphotos-uploader run
    ```

3. You should get an output similiar to this one (assuming the example above):

    ```
    2019/09/14 09:20:45 Token has not been retrieved from token store: failed retrieving token from keyring
    2019/09/14 09:20:45 Open http://192.168.0.123.nip.io:12345
    ```

    Open the the authentication URL in your main browser, select the account you want to use and allow _docker-gphotos-uploader_ access to your Google Account to "View and manage your Google Photos library".
4. Once the authentication process is complete you should get a breen box with "Success!" and an additional message saying that you are authenticated.

The authentication process is now complete and `gphotos-uploader-cli` is ready to upload your photos on the background.

## Support Information

### Force run `gphotos-uploader-cli` upload task:

```
docker exec -it gphotos-uploader run
```

### Shell access whilst the container is running:

```
docker exec -it gphotos-uploader /bin/sh
```

### To monitor the logs of the container in real-time:

```
docker logs -f gphotos-uploader
```

## License

Use of this source code is governed by an MIT-style license that can be found in the [LICENSE](LICENSE) file.
