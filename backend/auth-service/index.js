const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { initializeApp } = require('firebase/app');
const { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut } = require('firebase/auth');
const axios = require('axios');  // Importando o Axios para enviar eventos para o Event Bus

const firebaseConfig = {
  apiKey: "AIzaSyDtsNBgEVJ1NJ5GqX3PCvOYSzb-CTRLDaI",
  authDomain: "futdle.firebaseapp.com",
  projectId: "futdle",
  storageBucket: "futdle.appspot.com",
  messagingSenderId: "754585551605",
  appId: "1:754585551605:web:31d87a95a62c14e810bbbc",
  measurementId: "G-WC9N2M4DB9"
};

const firebaseApp = initializeApp(firebaseConfig);
const auth = getAuth(firebaseApp);

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    
    // Sorteia o jogador secreto
    const { data: secretPlayer } = await axios.get('http://localhost:3002/secret-player');

    // Manda o Evento pro Event Bus
    axios.post('http://localhost:3003/events', {
      type: 'Usuario Logado',
      data: {
        id: userCredential.user.uid,
        email: userCredential.user.email,
        secretPlayer: secretPlayer // Inclui o jogador secreto no evento
      }
    }).catch((err) => {
      console.log('Erro enviando evento pro Event Bus', err.message);
    });

    res.status(200).send({
      user: userCredential.user,
      secretPlayer: secretPlayer // Envia o jogador secreto diretamente para o frontend
    });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

app.post('/signup', async (req, res) => {
  const { email, password } = req.body;

  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    
    // Sorteia o jogador secreto
    const { data: secretPlayer } = await axios.get('http://localhost:3002/secret-player');

    // Manda o Evento pro Event Bus
    axios.post('http://localhost:3003/events', {
      type: 'Usuario Criado',
      data: {
        id: userCredential.user.uid,
        email: userCredential.user.email,
        secretPlayer: secretPlayer // Inclui o jogador secreto no evento
      }
    }).catch((err) => {
      console.log('Erro enviando evento pro Event Bus', err.message);
    });

    res.status(201).send({
      user: userCredential.user,
      secretPlayer: secretPlayer // Envia o jogador secreto diretamente para o frontend
    });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

app.post('/logout', (req, res) => {
  signOut(auth)
    .then(() => {
      // Manda o Evento pro Event Bus
      axios.post('http://localhost:3003/events', {
        type: 'Usuario Deslogado',
        data: { message: 'Usuário deslogado com sucesso' }
      }).catch((err) => {
        console.log('Erro enviando evento pro Event Bus', err.message);
      });

      res.status(200).send({ message: 'Usuário deslogado com sucesso' });
    })
    .catch(error => {
      res.status(400).send({ error: error.message });
    });
});

app.post('/events', (req, res) => {
  console.log('Evento recebido:', req.body.type);
  res.send({});
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Serviço de Autenticação rodando na porta: ${PORT}`);
});
