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

The `gphotos-uploader-cli` tool will automatically run in the background every 8 hours by default. Also, don't forget to replace `{PATH_TO_CONFIGURATION}` and `{PATH_TO_PHOTOS_LIBRARY}` with your host machine absolute paths. Please check the documentation below for more detailed information on all the configuration parameters.

A `/config/config.hsjon` file will be created when the container runs for the first time with configuration defaults for `gphotos-uploader-cli`. Open it in your favorite text editor and tweak the options to your preference. Refer to the [Authentication](#authentication) section below to properly set your `APIAppCredentials` and the official [configuration documentation](https://github.com/nmrshll/gphotos-uploader-cli/blob/master/.docs/configuration.md) for all other options.

### Container configuration parameters

Container images are configured using parameters passed at run-time (such as those above). Some of these parameters are separated by a colon and indicate `<external>:<internal>` respectively.

| Parameter | Description |
| :----: | --- |
| `-e GPU_SCHEDULE="0 */8 * * *"` | Background task schedule expression (see [crontab.guru](https://crontab.guru/)). |
| `-v {PATH_TO_CONFIGURATION}:/config` | Absolute host path to store `gphotos-uploader-cli` configuration. |
| `-v {PATH_TO_PHOTOS_LIBRARY}:/photos` | Absolute host path for the photos library source folder. |

## Authentication

Given that `gphotos-uploader-cli` uses OAuth 2 to access Google APIs, authentication is a bit tricky and envolves a few manual steps. Please follow the guide below to carefully give `gphotos-uploader-cli` the required access to your Google Photos account.

### API credentials

Before you can use `gphotos-uploader-cli`, you must enable the Photos Library API and request an OAuth 2.0 Client ID.

1. Make sure you're logged in into the Google Account where you want your photos uploaded to.
2. Start by [creating a new project](https://console.cloud.google.com/projectcreate) in Google Cloud Platform and give it a name (example: _Google Photos Uploader_).
3. Enable the [Google Photos Library API](https://console.cloud.google.com/apis/library/photoslibrary.googleapis.com) by clicking the <kbd>ENABLE</kbd> button.
4. Configure the [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent) by setting the application name (example: _docker-gphotos-uploader_) and then click the <kbd>Save</kbd> button on the bottom.
5. Create [credentials](https://console.cloud.google.com/apis/credentials) by clicking the **Create credentials → OAuth client ID** option, then pick **Other** as the application type and give it a name (example: _gphotos-uploader-cli_).
6. Copy the **Client ID** and the **Client Secret** and keep them ready for use in the next section.

### CLI authentication

Once an OAuth 2.0 Client ID is generated, it's time to authenticate `gphotos-uploader-cli` against your Google Account for proper access to your Google Photos account.

_The following steps assume the container has been created and it's running. If not, please refer to the [create and start the container](#create-and-start-the-container) section above before continuing._

1. Open the `/config/config.hsjon` file and set the `ClientID` and `ClientSecret` options to the ones generated on the previous section.
2. Open your favorite terminal and run the following command to start the authentication process:

    ```
    docker exec -it gphotos-uploader oauth.sh start
    ```

3. You should get an output similiar to this one:

    ```
    2019/02/05 09:22:23 Error finding credential
    2019/02/05 09:22:23 Need to log login into account {ACCOUNT_EMAIL}
    2019/02/05 09:22:25 You will now be taken to your browser for authentication or open the url below in a browser.
    2019/02/05 09:22:25 https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id={API_CLIENT_ID}&login_hint={ACCOUNT_EMAIL}&redirect_uri=http%3A%2F%2F127.0.0.1%3A14565%2Foauth%2Fcallback&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fphotoslibrary&state={STATE}
    2019/02/05 09:22:25 If you are opening the url manually on a different machine you will need to curl the result url on this machine manually.
    2019/02/05 09:22:26 Failed to open browser, you MUST do the manual process.
    2019/02/05 09:22:26 Authentication will be cancelled in 120 seconds
    ```

    Open the the authentication URL in your main browser and allow _docker-gphotos-uploader_ access to your Google Account to "View and manage your Google Photos library".
4. You're now supposed to be redirect to a page that **will not open**. You'll get a message like "unable to connect" or "this site can't be reached", depending on your browser. Worry not, just copy the URL from the browser address the bar and run the following command on a **new terminal** window:

    ```
    docker exec -it gphotos-uploader oauth.sh store-token "{URL_COPIED_FROM_THE_ADDRESS_BAR}"
    ```

    _Please notice the double quotes surrounding the URL, do not remove those._

5. Once the previous step is done, you should've got the following output on your **first terminal** window:

    ```
    2019/02/05 09:37:41 stored token for user: {ACCOUNT_EMAIL}
    2019/02/05 09:37:41 Shutting down server...
    Server gracefully stopped
    all uploads done
    all deletions done
    ```

You're now authenticated against your Google Account and `gphotos-uploader-cli` has the required access to your Google Photos account to read and upload new photos.

## Support

### Force run `gphotos-uploader-cli` upload task:

```
docker exec -it gphotos-uploader gphotos-uploader-cli
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
