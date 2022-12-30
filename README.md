## How to Create a DIY Docker Container for Your Unraid Server

Unraid is awesome, and so are Docker containers. You may have installed Docker images through Community Applications before, but did not realize how easy it is to create your own from scratch.

In this guide I will cover:

1. Setting up a basic HTTP server with node (our application)
2. Publishing an image to hub.docker.com
3. Running the Application on an Unraid Server

---

#### Prerequisites

You will need to have the following installed on your system:

- node/npm
- docker
- docker-compose

---

#### 1) Setting up a Basic HTTP Server with Node

You can download [my repository](https://github.com/adalfonso/hello-server) as the basis for your application.

Install dependencies with `npm i`.

For this application I decided to create an HTTP server with [nodejs](https://nodejs.org/en/) & [Typescript](https://www.typescriptlang.org/), but you can adapt your application to use any technologies you want.

The source is dead simple. It's just a [hello world](https://expressjs.com/en/starter/hello-world.html) for expressjs:

```javascript
import express from "express";

const app = express();
const port = 3000;

app.get("/", (_req, res) => {
  res.send("Hello World!");
});

app.listen(port, () => {
  console.log(`Server listening on ${port}`);
});
```

All this does is start an HTTP server with a single route, `/`, which just displays the text `Hello World!`. It's perfect to test that the entire process works, but not very useful otherwise.

Next, we need a `Dockerfile`:

```docker
FROM node:18-alpine
WORKDIR /usr/src/app
COPY package.json .
RUN npm install --silent
COPY . .
EXPOSE 3000
CMD ["npm","start"]
```

And `docker-compose.yml`:

```yaml
version: "3.8"

services:
  app:
    build:
      context: .
    ports:
      - 3000:3000
    volumes:
      - ./:/usr/src/app
      - /usr/src/app/node_modules/
    command: npm run start
```

If you want to do anything fancy like configure ports, add local storage volumes, or set up a database, you will have to make additional changes to these Docker files as necessary.

For local development you can verify that your container builds by running:

```bash
npm run docker
```

Once the container is running you can check `http://localhost:3000` to verify that the server is working properly.

And that's about it for the code.

---

#### 2) Publishing an Image to hub.docker.com

Sign up for an account on https://hub.docker.com. I created a free account which allows for unlimited public repos, and one private repo.

Next, create a repository where you will provide the `Name` of your application.

From there we need to log into Docker from our machine:

```bash
docker login
```

Enter your username and password.

Next, you're ready to build & tag, then publish.

Notice the `build` and `publish` scripts in `package.json`:

```bash
"build": "docker build -t adalfonso/hello-server:latest .",
"publish": "docker push adalfonso/hello-server:latest"
```

You will want to replace `adalfonso` with _your_ Docker username, and `hello-server` with whatever your application is called for these scripts.

I'm using `latest` somewhat haphazardly as my tag version which will overwrite the previous version each time I build, tag and publish. If you're concerned with tagging proper version, I recommend you perform this process manually, or come up with a new workflow that suits you.

Once you've adapted these scripts you can simply:

```bash
npm run build
```

and

```bash
npm run publish
```

You should now be able to see your latest tag on your Docker repo.

---

#### 3) Running the Application on an Unraid Server

Go to the `Docker` tab in your Unraid server and click `Add Container`.

- Provide a `Name`
- Set the repository to be of the format `username/repository`, e.g. `adalfonso/hello-server`
- Set the `Network Type` to `Host`

Then visit `http://your_unraid_server:3000`

And that's it!
