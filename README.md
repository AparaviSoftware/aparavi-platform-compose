# Docker Compose for Aparavi

## Starting the services
1. **Prepare the runtime environment**: Copy the `docker-compose.yml` file to a clean working directory. Starting the services will create the following directory structure. Optionally, you may pre-populate these directories with data prior to starting the containers.

    ```
    __$CWD/
      |__appagent-config
      |__appagent-data
      |__mysql-data
      |__platform-config
      |__platform-data
      |__source-data
    ```

2. **Start the container services**: Run the containers locally
    
    `docker compose up -d`

3. **Navigate to http://localhost**: After the services are up and running, access Aparavi by opening a web browser and navigating to http://localhost:xxxxx. Where xxxx is the port assign to the platform container.

4. **Login to Aparavi using root:root**: Once you access Aparavi via the provided URL, log in with the username "root" and the password "root" as instructed.

Remember to replace "localhost" with the appropriate hostname or IP address if you're accessing the service from a remote machine. Also, ensure that the necessary ports are open and not blocked by any firewall settings.

5. **Activate the deployed Aparavi platform**: Every new platform deployment will need to be activated. If you are re-deploying a platform that was previously activated and is using the existing config and data folders no additional activation is needed. Retrieve activation code by filling out form here: http://bit.ly/3vMghl4. On the Platform UI, navigate to `Administration>Activate` and enter the activation code as shown below. Every code can only be used once. 

<img width="960" alt="Activate" src="https://github.com/AparaviSoftware/DockerCompose/assets/59745347/f3b52cd4-7482-4f3d-bb9c-40a31df58df6">

> ## NOTE: Activation flow for 2.15 will not work until preview.aparavi.com is updated to 2.15
> The activation flow relies on the upstream Platform (e.g. preview.aparavi.com) to be the same version or later than the version being deployed. If the deployed container has a platform version later than upstream, you will see the activation looping in the container logs
> ```
> 6/18/2024, 01:57:34 PM ENTRY.SH: Waiting for Activation Code...
> 06:57:44 6/18/2024, 01:57:44 PM ENTRY.SH: [WARNING] Activation failed; unable to pull activation code from upstream platform. Contact support@aparavi.com for help.
> ```

6. **Add Documents to Discover**: Once the Aparavi platform is deployed you can add data to the \source-data\ folder that was created in the directory that the docker-compose.yaml was placed. Any data that is added to this folder will be analyzed by the platform. You can also add File Shares, M365, S3, Azure Blob, plus more under the sources settings.

7. **Get Help or More Information**: Feel free to use the help system within the Aparavi platform by clicking the magnifying glass in the bottom right corner once you are logged in. Contact us at support@aparavi.com with any issues or inquires about the paid features of the Aparavi platform. 