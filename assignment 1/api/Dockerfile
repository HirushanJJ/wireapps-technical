# Parent Image Node.js
FROM node:18

#Working Directory Defining
WORKDIR /usr/src/app

#Copy Package.json
COPY Package.json ./

#Dependancy Installation
RUN npm Installation

#Copy the Applicaiton files
COPY . .

#Run the Applicaiton
CMD [ "node", "app.js" ]
