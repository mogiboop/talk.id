# talk.id

This project aims to help patients who have undergone a tracheostomy — and are therefore unable to express any form of verbal communication — as well as nurses, in a hospital context, in order to facilitate communication and interaction between both.

<p align="center">
  <img src="/assets/logo_website.png" alt="Project icon"/>
</p>

## Table of Contents

- [Installation](#installation)
- [How To Use](#how-to-use)
- [Developers](#developers)

## Installation

Flutter                    |         PostgreSQL        | Python
:-------------------------:|:-------------------------:|:-------------------------:
![flutter](/assets/flutter.png)  |  ![postgresql](assets/postgresql.png) | ![python](assets/python.png)


Steps to install the project:

1. Install technologies/frameworks.

   [Flutter (3.22.0)](https://github.com/flutter/flutter.git)
   [PostgreSQL](https://www.postgresql.org/download/)
   [Python (3.9.5)](https://www.python.org/downloads/release/python-395/)
> It is recommended to use these versions of Python and Flutter to avoid version conflicts

2. Clone the repository:
    ```sh
    git clone https://github.com/mogiboop/talk.id.git
    ```

3. Create and activate a Python virtual environment (venv):
    ```sh
    python -m venv path_to_venv
    
    path_to_venv\Scripts\activate
    ```

4. In the Flutter environment, run:
    ```dart
    flutter pub get
    ```
    In the Python environment, run:
    ```py
    pip install -r requirements.txt
    ```

5. Create a __.env__ file in the Django project root, inside the __app_comm__ directory:
    ```
    SECRET_KEY = ...
    DEBUG = ...
    DJANGO_ALLOWED_HOSTS= ...
    POSTGRES_DB_NAME = ...
    POSTGRES_USER = ...
    POSTGRES_PASSWORD = ...
    POSTGRES_HOST = ...
    POSTGRES_PORT = ...
    REDIS_HOST=...
    REDIS_PORT=...
    DJANGO_SECURE_SSL_REDIRECT=...
    WEB_PUSH_VAPID_PUB_KEY = ...
    WEB_PUSH_VAPID_PRIV_KEY = ...
    WEB_PUSH_VAPID_ADMIN_EMAIL = ...
    
    SUPERUSER_USERNAME = ...
    SUPERUSER_EMAIL = ...
    SUPERUSER_PASSWORD = ...
    SUPERUSER_FIRST_NAME = ...
    SUPERUSER_LAST_NAME = ...
    ```
    > In the DJANGO_ALLOWED_HOSTS parameter, domains must be defined separated by commas.

 6. Run the applications:
    
    - On localhost:
      
      After completing the steps above, you can run the project locally.

      The following command will migrate Django models to the PostgreSQL database, as defined in the __.env__ file:
      ```py
      python manage.py migrate
      ```

      Configure the CHANNEL_LAYERS variable according to the environment:
      
      - For localhost environments, use the inMemoryChannel from the channels package
      - For production environments, it is recommended to use something more robust, such as a Redis server
      
      Finally, the following command will start the server locally:
      ```py
      python manage.py runserver
      ```

      To start the mobile app, run the following command in the __app__ directory:
      
      ```dart
      flutter run
      ```

    - Deploy:
      
      To deploy, you’ll need a web service where the web app and an application server (such as Daphne for async or Gunicorn for sync) will be hosted.
      
      It is also recommended to deploy the database.
      
      All servers used in the web app should also be deployed.
      
      The environment variables defined in the .env file must be copied over into the web service settings.

## How To Use

After everything is running, an initial superuser will have been created in the database with full permissions in the project.

This superuser can create accounts for patients, nurses and other superusers/admins.

In order to test the project, you must create at least one Patient account, which will be used to log into the mobile app.


## Developers:
This project was developed by students from [ISEL - Instituto Superior de Engenharia de Lisboa](https://www.isel.pt/), in partnership with [ESEL - Escola Superior de Enfermagem de Lisboa](https://www.esel.pt/):
- Miguel Leitão A46309
- Rui Correia A48594
- Tiago Figueiredo A49154




