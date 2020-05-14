# Deployment of the MaxScale Test Visualizer

The deployment is done using the Docker Compose

## Deployment procedure

1. Install the [Docker Compose](https://docs.docker.com/compose/install/) on the machine.
2. Clone repository on the machine that will run the visualizer
3. Create the `.env` file in the docker directory. Use the env-template as a reference. Specify:
    * The database connection information in the form of the URI.  
    * The rails secret base.
4. Build Docker containers for the deployment: `docker-compose build`
5. Start the application in background mode: `docker-compose up -d`

The application will run on 8001 port. It must be used by reverse-proxies.
