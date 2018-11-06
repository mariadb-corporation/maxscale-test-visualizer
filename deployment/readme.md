# Deployment of the MaxScale Test Visualizer

The deployment is done using the Chef and a set of custom scripts that issue chef-solo on the remote server.

## Deployment procedure

1. Install the [Chef DK](https://downloads.chef.io/chefdk) for your system. The installation procedure was used with 2.4.17 stable release.
2. Install `net-ssh` and `net-scp` gems.
3. Fill-in the template of the rails application role. Template is located in `roles/rails-app.json.template`. Copy it into `roles/rails-app.json` file and fill-in attributes:
   * Username and password for the database.
   * Rails secret.
   * GitHub application id and key.
4. Run the deployment script: `./deploy.rb -s 10.9.8.7 -u user -j configs/rails-app.json`.

## Configure users that allow to enter the application

1. Open file `rails-app/config/settings.yml`.
2. Modify the list of users in Authentication->Users.
3. Restart the application using `sudo systemctl restart maxscale-test-visualizer` if you did not change the application name.
