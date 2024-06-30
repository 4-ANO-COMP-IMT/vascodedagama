import React, { useState } from 'react';
import axios from 'axios';
import './App.css';

const App = () => {
  const [playerName, setPlayerName] = useState('');
  const [player, setPlayer] = useState(null);

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

  return (
    <div className="App">
      <header className="App-header">
        <h1>Championsdle</h1>
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
};

export default App;
