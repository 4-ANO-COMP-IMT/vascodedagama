# Championsdle

## Descrição

Championsdle é uma aplicação web interativa e divertida onde os usuários podem adivinhar características de jogadores de futebol. Inspirado no famoso jogo de palavras "Wordle", Championsdle traz uma abordagem esportiva e educativa, permitindo que os fãs de futebol testem seus conhecimentos sobre jogadores de diferentes ligas e equipes.

### Benefícios

- **Entretenimento Educativo**: Aprenda mais sobre seus jogadores favoritos enquanto se diverte.
- **Interação Social**: Compartilhe suas pontuações com amigos e veja quem sabe mais sobre futebol.
- **Atualizações Regulares**: Novos jogadores e desafios adicionados constantemente.

### Como Jogar

O Championsdle é um jogo que desafia você a adivinhar um jogador secreto de futebol. Você tem seis tentativas para descobrir quem é o jogador, usando as dicas fornecidas. Após cada palpite, você receberá dicas sobre os atributos do jogador.

Dicas:

- Verde: Significa que o atributo está correto.
- Vermelho: Significa que o atributo está incorreto.
- Vermelho com seta para baixo (⬇️): Significa que o atributo é maior do que o do jogador secreto.
- Vermelho com seta para cima (⬆️): Significa que o atributo é menor do que o do jogador secreto.

## Vídeo demonstrativo
https://www.youtube.com/watch?v=cOrK03OSrUk

## Setup
### Estrutura de Pastasgit reflog

- **Backend:** Pasta do back-end | Estrutura Node.js
- **Frontend:** Pasta do front-end | Estrutura React


### Como Utilizar
**Clone o Repositório**

```sh
git clone https://github.com/4-ANO-COMP-IMT/vascodedagama.git
cd vascodedagama
```

**Crie e preencha o arquivo .env, utilizando o arquivo .env.example como exemplo:**

```
FIREBASE_API_KEY=
FIREBASE_AUTH_DOMAIN=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_APP_ID=
FIREBASE_MEASUREMENT_ID=
```

#### Kubernetes/Docker

**Caso use kubernetes, realize os deployments:**
```sh
cd backend

cd implantacao

kubectl apply -f eventbus-deployment.yaml
kubectl apply -f authservice-deployment.yaml
kubectl apply -f authservice-service.yaml
kubectl apply -f playerservice-deployment.yaml
kubectl apply -f playerservice-service.yaml
```

**Para verificar o deployment:**
```sh
kubectl get deployments
kubectl get pods
```

**Para realizar requests para os microsserviços:**
```sh
kubectl get services
```

Pegue a porta definida pelo serviço NodePort. A url será com a porta definida pelo serviço (http://localhost:<NODE_PORT>/).

#### Microsserviços localmente
**Caso use os microsserviços localmente, instale as dependências dos serviços do back-end individualmente:**

```sh
cd backend

cd auth-service
npm install

cd ..

cd player-service
npm install

cd ..

cd event-bus
npm install
```
**Inicie os serviços do back-end:**

```sh
cd ..
cd backend
npm install -g concurrently
npm run start-all
```

### Inicie o servidor front-end React:

```sh
cd ..
cd frontend
cd championsdle-frontend
npm install
npm start
```
Acesse a aplicação via navegador no endereço http://localhost:3000.

### Inicie o servidor front-end Flutter:

```sh
cd ..
cd frontend
cd frontend_flutter
flutter run -d chrome --web-renderer html
```

# Backend Módulos

## Serviço de Autenticação (http://localhost:3001/)
- **POST /signup**

### Request

```sh
{
  "email": "teste12@gmail.com",
  "password": "senha1"
}
```

### Response

```sh
{
  "uid": "sNCmqbZRuBPVGc4PVcS3zb4D4X22",
  "email": "teste12@gmail.com",
  "emailVerified": false,
  "isAnonymous": false,
  "providerData": [
    {
      "providerId": "password",
      "uid": "teste12@gmail.com",
      "displayName": null,
      "email": "teste12@gmail.com",
      "phoneNumber": null,
      "photoURL": null
    }
  ],
  "stsTokenManager": {
    "refreshToken": "AMf-vByER2KQCbzF8wUZRJltWmeb1fgTCAnDn5UcGFT0gWWdtx_xN0DuZkIUqhfvMTLFPb3MzsM8LNJ8Z7hCIOkApRyajwFt2X3yOAHYRGGUY8Z8AeUbiHfF2k_zS_gXgqTfwJR5GkFq2_6ZZMkuo_H6Vz1HMD0rbYFE4FGLR-uXgnWUigb0lKc_l55DvvD40a4cr1Mr16gy",
    "accessToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijc5M2Y3N2Q0N2ViOTBiZjRiYTA5YjBiNWFkYzk2ODRlZTg1NzJlZTYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZnV0ZGxlIiwiYXVkIjoiZnV0ZGxlIiwiYXV0aF90aW1lIjoxNzE5NzY5NzMzLCJ1c2VyX2lkIjoic05DbXFiWlJ1QlBWR2M0UFZjUzN6YjRENFgyMiIsInN1YiI6InNOQ21xYlpSdUJQVkdjNFBWY1MzemI0RDRYMjIiLCJpYXQiOjE3MTk3Njk3MzMsImV4cCI6MTcxOTc3MzMzMywiZW1haWwiOiJjYWZtbzIzMUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiY2FmbW8yMzFAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.SHUYgE4v8gmV8BnyM8mzPzPA8bbKiL6BVpvpy2vU85aFaa2iHoBcU8_KjCSKRrKvtO1rpZg0NIRZz_77-XEv4lxXkF9vN5SO5kIFIt7KVytzBP8wn8uAmqhwTNCzw07m-GLDQpb2xdQGmJcC3atURiKIgpW85kx_rcVcwMf2lwCJdZa6dNNUWSS1apvdu6lTRZP2v9VPavMhguPvxBWd-8yeW-AK-hhehrmd_rfQ88SD4ibjDirIdz3dR4f5ZJhr80EHH26v0vQ5Y3va-SBvDd5rBYlK_e6ETfWnrtEdVieaMFgZLtNW-pbEJtPWCbK0KfJZfotqCVbHdTI0PAodUg",
    "expirationTime": 1719773419047
  },
  "createdAt": "1719769733028",
  "lastLoginAt": "1719769733028",
  "apiKey": "???????",
  "appName": "[DEFAULT]"
}
```
- **POST /login**

### Request

```sh
{
  "email": "teste12@gmail.com",
  "password": "senha1"
}
```
### Response

```sh
{
  "uid": "1SJmOIjvpEP51Kv1fIGA4KsHRbw2",
  "email": "teste12@gmail.com",
  "emailVerified": false,
  "isAnonymous": false,
  "providerData": [
    {
      "providerId": "password",
      "uid": "teste12@gmail.com",
      "displayName": null,
      "email": "teste12@gmail.com",
      "phoneNumber": null,
      "photoURL": null
    }
  ],
  "stsTokenManager": {
    "refreshToken": "AMf-vByoQlSh0TdNUDJQ7NbgCON2QvA-o-THruNw5k41pCZGhUxSQJtynfWDFrb7ArdTMdMtkDM6PaIp8zi7vRSslGDCJnURwe5ndnMFaJnQyH8_cIiDod-BUHA5105v1tzBxYcLZwlbZdb6Hi4sDxkl0RYf6km3RmcWMgtVVS6nzS80MprwrilXjc5nAcrDZh_RVsx7VfTN",
    "accessToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijc5M2Y3N2Q0N2ViOTBiZjRiYTA5YjBiNWFkYzk2ODRlZTg1NzJlZTYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZnV0ZGxlIiwiYXVkIjoiZnV0ZGxlIiwiYXV0aF90aW1lIjoxNzE5NzY5NjM5LCJ1c2VyX2lkIjoiMVNKbU9JanZwRVA1MUt2MWZJR0E0S3NIUmJ3MiIsInN1YiI6IjFTSm1PSWp2cEVQNTFLdjFmSUdBNEtzSFJidzIiLCJpYXQiOjE3MTk3Njk2MzksImV4cCI6MTcxOTc3MzIzOSwiZW1haWwiOiJjYWZtbzIzMTJAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbImNhZm1vMjMxMkBnbWFpbC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9fQ.Mp9ozfjQ4MDEgv9B--0Y7J9NFvq6gV2Z0NRidxrghidxqEaLfdJPXvOCoq1NTp_E7xFK7qbDg34hwdUMQ0AvOYJvOBx2Q2jXfF2MzebY2oX-LCZ9e-AZyLzbQMpXn_tNu9o1ZZZOAasltqxPX6--Q_vwJRND18mOCmJwdPdAUNPex91lw8TbtwM_eIqjzeylRbqW4pwQuWCp_du0cvEAUNUYEY6Mb71HsoxL1E6hpdV873ZOourLLCmyE3I0DphqeKKE-izbuQDT06fRxtwQB2cxoh6bgNasLgizFUcD_KzbvQ1plwYqCzrYTzn2oMym6hSEXg9RhbGmsy1bXtSBQg",
    "expirationTime": 1719773324728
  },
  "createdAt": "1717027017014",
  "lastLoginAt": "1719769639116",
  "apiKey": "???????",
  "appName": "[DEFAULT]"
}
```

- **POST /logout**

### Request

```sh
{
  "email": "teste12@gmail.com",
  "password": "senha1"
}
```

### Response

```sh
{
  "message": "Usuário deslogado com sucesso"
}
```
## Serviço de Jogadores (http://localhost:3002/)
- **GET /players**

### Response

```sh
[
  {
    "id": 1,
    "name": "Jogador 1",
    "height": "180cm",
    "team": "Time A",
    "price": "10M",
    "foot": "Direito",
    "position": "Atacante",
    "league": "Premier League",
    "icon": "player1.png"
  }
]
```

- **POST /players**

### Request

```sh

{
    "name": "Jogador 2",
    "height": "188cm",
    "team": "Time B",
    "price": "5M",
    "foot": "Esquerdo",
    "position": "Zagueiro",
    "league": "La Liga",
    "icon": "player2.png"
}

```

### Response

```sh
{
  "id": 2,
    "name": "Jogador 2",
    "height": "188cm",
    "team": "Time B",
    "price": "5M",
    "foot": "Esquerdo",
    "position": "Zagueiro",
    "league": "La Liga",
    "icon": "player2.png"
}
```
## Eventos (http://localhost:3003/events)

- **POST /events**

### Request
```sh
{
  "type": "TestEvent",
  "data": {
    "message": "This is a test event"
  }
}
```

### Response
```sh
{
  "status": "OK"
}
```
- **GET /events**

### Response
```sh
  [
  {
    "type": "Usuario Criado",
    "data": {
      "id": "sNCmqbZRuBPVGc4PVcS3zb4D4X22",
      "email": "teste12@gmail.com"
    }
  },
    {
    "type": "Usuario Logado",
    "data": {
      "id": "1SJmOIjvpEP51Kv1fIGA4KsHRbw2",
      "email": "teste12@gmail.com"
    }
  },
  {
    "type": "Usuario Deslogado",
    "data": {
      "message": "Usuário deslogado com sucesso"
    }
  },
    {
    "type": "Novo Jogador Criado",
    "data": {
      "id": 2,
      "name": "Jogador 2",
      "height": "188cm",
      "team": "Time B",
      "price": "5M",
      "foot": "Esquerdo",
      "position": "Zagueiro",
      "league": "La Liga",
      "icon": "player2.png"
    }
  },
  {
    "type": "TestEvent",
    "data": {
      "message": "This is a test event"
    }
  }
]
```
## Autores
- **Nome:** Carlos Augusto Freire Maia de Oliveira 	    RA: 21.00781-0
- **Nome:** Cesar Fukushima Kim Bresciani 			    RA: 21.00478-0
- **Nome:** Enzo Leonardo Sabatelli de Moura 		    RA: 21.01535-0
- **Nome:** Estevan Delazari Feher 				        RA: 21.00586-9
- **Nome:** Gabriel Zendron Allievi 				    RA: 21.01350-0
- **Nome:** Joao Paulo de Souza Rodrigues 			    RA: 21.01809-9
