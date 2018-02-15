# Deployment of the MaxScale Test Visualizer

The deployment is done using the Chef and a set of custom

## Deployment procedure

1. Install the [Chef DK](https://downloads.chef.io/chefdk) for your system. The installation procedure was used with 2.4.17 stable release.
2. Install `net-ssh` and `net-scp` gems.
3. Fill-in the template of the rails application role. Template is located in `roles/rails-app.json.template`. Copy it into `roles/rails-app.json` file and fill-in attributes:
   * Username and password for the database.
   * Rails secret.
4. Run the deployment script: `./deploy.rb -s 10.9.8.7 -u user -j configs/rails-app.json`.
