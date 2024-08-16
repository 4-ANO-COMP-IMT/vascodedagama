import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const App = () => {
  const [playerName, setPlayerName] = useState('');
  const [player, setPlayer] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isCadastro, setCadastro] = useState(false);

  useEffect(() => {
    const loggedIn = localStorage.getItem('isLoggedIn');
    setIsLoggedIn(loggedIn === 'true');
  }, []);

  const handleSearch = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.get(`http://localhost:3002/players`);
      console.log('Player Data:', response.data); // Log player data

      // Acha o Jogador com o nome inserido
      const playerData = response.data.find(p => p.name.toLowerCase() === playerName.toLowerCase());
      
      if (playerData) {
        setPlayer(playerData);
      } else {
        setPlayer(null);
        alert('Player not found');
      }
    } catch (error) {
      console.error('Error fetching player data', error);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    try{
      const response = await axios.post('http://localhost:3001/login', {
        email: username,
        password: password
      });

      console.log('Response data: ',response.data);
      if(response.status === 200){
        setIsLoggedIn(true);
        localStorage.setItem('isLoggedIn','true');
      }
      else
        alert("Usuário inválido!");
    }catch(error){
      console.error('Error logging in:', error.response ? error.response.data : error.message);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('isLoggedIn');
    setIsLoggedIn(false);
  }

  const handleCadastro = async(e) => {
    console.log("valores: "+username+" e "+password);
    e.preventDefault();
    try{
      const response = await axios.post('http://localhost:3001/signup', {
        email: username,
        password: password
      });

      console.log("Response sign-up: "+response.data);
      if(response.status === 201){
        setCadastro(false);
      }
      else 
        alert("Falha no cadastro!");
    }catch(error){
      console.error('Error logging in:', error.response ? error.response.data : error.message);
    }
  };

  if (isCadastro) {
    return (
      <div className="App">
        <header className="App-header">
          <h1>Cadastro</h1>
          <form onSubmit={handleCadastro}>
            <div className="input-container">
              <input
                className="style-login"
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
              <input
                className="style-login"
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <div>
              <button
                className="style-login"
                onClick={() => setCadastro(false)}
              >
                Voltar ao Login
              </button>
              <button className="style-login" type="submit">
                Cadastrar
              </button>
            </div>
          </form>
        </header>
      </div>
    );
  }
  else if(!isLoggedIn && !isCadastro){
    console.log("valor do cadastro: "+isCadastro);
    return (
      <div className="App">
        <header className="App-header">
          <h1>LOGIN</h1>
          <form onSubmit={handleLogin}>
            <div class="input-container">
              <input class="style-login"
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
              <input class="style-login"
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <div>
              <button class="style-login" onClick={(e) => {e.preventDefault();
                                                           setCadastro(true)}}>Cadastrar</button>
              <button class="style-login" type="submit">Login</button>
            </div>
          </form>
        </header>
      </div>
    );
  }
  else{
    return (
      <div className="App">
        <header className="App-header">
          <h1>Championsdle</h1>
          <button onClick={handleLogout}>Logout</button>
          <form onSubmit={handleSearch}>
            <input
              type="text"
              placeholder="Inserir nome de Jogador"
              value={playerName}
              onChange={(e) => setPlayerName(e.target.value)}
            />
            <button type="submit">Palpitar</button>
          </form>
          {player && (
            <div className="player-info">
              <img src={player.icon} alt={player.name} className="player-icon" />
              <div className="player-details">
                <div className="player-attribute">Nome: {player.name}</div>
                <div className="player-attribute">Altura: {player.height}</div>
                <div className="player-attribute">Time: {player.team}</div>
                <div className="player-attribute">Preço: {player.price}</div>
                <div className="player-attribute">Pé: {player.foot}</div>
                <div className="player-attribute">Posição: {player.position}</div>
                <div className="player-attribute">Liga: {player.league}</div>
              </div>
            </div>
          )}
        </header>
      </div>
    );
  }
};

export default App;
