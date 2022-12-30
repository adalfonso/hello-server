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