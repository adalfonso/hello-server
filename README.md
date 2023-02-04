## How to Create a DIY Docker Container for Your Unraid Server

Unraid is awesome, and so are Docker containers. I've been using Docker images from Community Applications on Unraid for years, and have always kinda wondered how hard it would be to just create my own from scratch. Turns out it was actually pretty straight forward, and I want share the process I went through to make it happen

In this guide I will cover:

1. Setting up a basic HTTP server with node (our application)
2. Publishing an image to hub.docker.com
3. Running the container on an Unraid Server

---

#### Prerequisites

You will need to have the following programs installed the system where you will develop and test this on:

- git
- node/npm
- docker
- docker-compose

---

#### 1) Setting up a Basic HTTP Server with Node

Download [my repository](https://github.com/adalfonso/hello-server) as the basis for your application. I will not go over every file in exact detail, but I will cover the highlights.

Clone the repo:

```bash
git clone https://github.com/adalfonso/hello-server.git
```

Enter repo and install:

```bash
cd hello-server && npm i
```

For this application I decided to create an HTTP server with [nodejs](https://nodejs.org/en/) and [Typescript](https://www.typescriptlang.org/); two technologies that I use regularly which are pretty lean for this quick project. However, you can adapt your application to use any technologies you want.

The source is dead simple. It's just a [hello world](https://expressjs.com/en/starter/hello-world.html) for expressjs:

```javascript
import express from "express";

const app = express();
const port = 3000;

app.get("/", (_req, res) => {
  res.send("Hello World!");
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
```

All this does is start an HTTP server with a single route, `/`, which just displays the text `Hello World!`. It's perfect to test that the entire process works, but not very useful otherwise.

Next, we need a `Dockerfile`:

```docker
# Base image - node v18 LTS
FROM node:18-alpine

# Working directory where the below commands get executed
WORKDIR /usr/src/app

# Copy package.json & package-lock.json to working directory
COPY package*.json ./

# Copy source code into working directory
COPY src ./src

# Copy tsconfig
COPY tsconfig.json .

# Install npm packages
RUN npm i
```

`Dockerfile` configures how Docker builds the image, including which base image to use. As I am using the current node LTS, I went with `node:18-alpine`.

And `docker-compose.yml`:

```yaml
version: "3.8"

services:
  app:
    build:
      context: .
    ports:
      - 3000:3000
    command: npm start
```

`docker-compose.yml` allows me to manage my Docker containers locally via `docker-compose`. This is much more convenient in the long run as I can pre-configure how the container interacts with its host system without having to run a bunch of `docker` commands manually.

**n.b.** Unraid does not use `docker-compose` by default and will rely solely on the Dockerfile.

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

From there we need to log in to Docker from our machine:

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

---

#### Bonus - Choose Port on Unraid Server

Let's customize the port that our container uses on the server and edit the container.

- Change `Network Type` to bridge.
- Click `Add another Path, Port...`
- Set `Config Type` to `Path`
- Name it something like "Hello Server Port"
- Choose `3000` for the `Container Port`
- Choose whatever port number you want for `Host Port`
