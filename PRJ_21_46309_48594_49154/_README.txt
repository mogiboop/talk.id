Projeto TalkID

Este projeto visa ajudar os pacientes que passaram pelo processo de traqueostomia, inibidos de expressar qualquer tipo de comunicação verbal, e enfermeiros num contexto hospitalar de modo a facilitar a comunicação e interação entre ambos. Para isso foi criado uma app movel e uma web app que comunicam entre si expressando as necessidades dos utilizadores.

Instalação:
Passos a seguir para instalar o projeto:

1. Instalar frameworks:
   Flutter (3.22.0): https://github.com/flutter/flutter.git
   PostgreSQL: https://www.postgresql.org/download/
   Python (3.9.5): https://www.python.org/downloads/release/python-395/
> Nota: Nestas frameworks as versões no Pyhton e Flutter é recomendado serem estas para uma mais fácil instalação e não haver conflictos de versões, apesar de ser possível com outras versões no caso do Flutter poderá gerar alguns conflitos com os packages no pubspec.yaml file mas possivelmente fáceis de resolver alterando a versão para a indicada no problema, assim como no Python.

2. Clonar o repositório:
    Obter os ficheiros do projeto fazendo clone do mesmo com o seguinte comando:
    git clone https://github.com/Carapinha02/projeto_talkID
    
3. Instalar packages:
    Para instalação dos packages, no flutter, basta ir ao até ficheiro pubspec.yaml, na diretoria app, e fazer pub get, comando:
    flutter pub get

    No python basta ir até ao ficheiro requirements.txt, na diretoria app_comm, e fazer o seguinte comando:
    pip install -r requirements.txt
    
    > Nota: No entanto este comando para obter os packages do python, no caso de utilização de um venv, deve ser feito primeiramente os dois primeiros comandos referidos no passo 5., após activação do venv.

4. Crie um ficheiro .env:
   Crie um ficheiro .env na root do projeto Django, diretoria app_comm, para armazenar variáveis que não devem ser partilhadas e devem permanecer seguras, crie algo deste género:
    
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
    
    > Nota: No parâmetro DJANGO_ALLOWED_HOSTS deve ser definido os domains separado por vírgulas.

 5. Correr as aplicações:
    - No localhost:
      Para correr no localhost basta ter os passos acima referidos feitos e configurados para tal e deverá ter criada a base de dados no PostrgeSQL de acordo com as configurações que pôs no ficheiro .env assim sendo para começar usar a mesma e criar os primeiros dados na mesma deverá (recomendado) criar um virtual environment(venv) pelo comando:
      python -m venv name_venv

      para ativar o mesmo basta fazer:
      name_venv\Scripts\activate

      Posteriormente desloque-se até à diretoria onde tem o projeto, na diretoria root do django app_comm onde se encontra o ficheiro manage.py,  faça o comando migrate para criar todas as tabelas e dados iniciais precisos para correr o projeto:
      python manage.py migrate

      Configure agora a variável CHANNEL_LAYERS de acordo com o que pretende, se apenas estiver a usar no localhost pode usar o inMemoryChannel do package channels, para ambientes de produção convém ter algo mais robusto como por exemplo um servidor Redis.
      
      Com isto poderá fazer runserver e assim correr o servidor na máquina local:
      python manage.py runserver

      Assim sendo a web app está pronta e só será preciso agora correr a aplicação móvel Flutter correndo um emulador e dando play no seu editor ou correndo o seguinte comando:
      flutter run

    - Deploy:
      Para fazer deploy precisará de um web service na qual fará o deploy da web application e de um application server, por exemplo, daphne(async) e gunicorn(sync), é também aconselhado fazer o deploy da database pois é mais confiável e seguro tendo maior escalabilidade e performance, todos os servidores usados na web application também podem/devem ser deployed. Este processo normalmente possui alguns custos pois free tem muitas limitações.
      Ainda no deploy as variáveis do ambiente definidas no ficheiro .env terão que ser transportadas/copiadas para as settings do web service assim como deverá descrever possíveis comandos para correr a web app num procfile.

Como usar:
Após ter tudo a correr e pronto a usar, terá sido criado na base de dados um primeiro utilizador como superuser, quando executou o comando migrate, o qual tem todas as permissões no projeto. Dado isto, ele pode criar contas para pacientes, enfermeiros e/ou superusers/admins. Assim, sendo para utilizar todo o projeto deverá criar pelo menos uma conta de Paciente entrando com as credenciais do primeiro superuserer no localhost, após ter sido criada essa conta já consegue usar a mobile app e o website num contexto real.
Neste caso sendo um superuser poderá entrar nas 2 apps e "testar" todas as funcionalidades.


Desenvolvedores:
Este trabalho foi desenvolvido por alunos do ISEL(Instituto Superior de Engenharia de Lisboa) em Parceria com a Esel(Escola Superior de Enfermagem de Lisboa), sendo eles:
- Miguel Leitão A46309
- Rui Correia A48594
- Tiago Figueiredo A49154