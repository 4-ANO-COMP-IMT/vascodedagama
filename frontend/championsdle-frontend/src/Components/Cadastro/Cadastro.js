import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Cadastro.css';

const Cadastro = ({onCadastroSucess}) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');

    const handleCadastro = async (e) => {
        e.preventDefault();
        try {
          await axios.post('http://localhost:3001/signup', {
            email: username,
            password: password
          });
          alert('Cadastro realizado com sucesso! Faça login.');
          onCadastroSucess(true);
        } catch (error) {
          console.error('Erro ao cadastrar:', error);
          alert('Erro ao realizar cadastro.');
        }
      };

      return(
        <main className="Cadastro-App">
            <header className="Cadastro-header">
                <h1>Cadastro</h1>
            </header>
            <form onSubmit={handleCadastro} className="cadastro-container">
                <input
                    className="form-input"
                    type="text"
                    placeholder="Username"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                />
                <input
                    className="form-input"
                    type="password"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                />
                <section className='cadastro-container-buttons'>
                    <button className="cadastro-button" 
                        onClick={(e) => { e.preventDefault(); onCadastroSucess(true);
                        }}>
                        Voltar
                    </button>
                    <button className="cadastro-button" type="submit">
                        Cadastrar
                    </button>
                </section>
            </form>
        </main>
      )
}

export default Cadastro;