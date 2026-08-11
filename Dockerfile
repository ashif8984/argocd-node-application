# Use the official Node.js 18 image based on Alpine Linux (lightweight)
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 3000 so the app can be accessed
EXPOSE 3000

# Command to run the app
CMD ["npm", "start"]