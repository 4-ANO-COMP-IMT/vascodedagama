import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Cadastro from '../Cadastro/Cadastro';
import './Login.css';

const Login = ({onLoginSucess}) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [cadastro, setCadastro] = useState(false);

    const handleLogin = async (e) => {
        e.preventDefault();
        try {
        const response = await axios.post('http://localhost:3001/login', {
            email: username,
            password: password
        });

        localStorage.setItem('isLoggedIn', 'true');
        localStorage.setItem('secretPlayer', JSON.stringify(response.data.secretPlayer));
        onLoginSucess(response.data.secretPlayer);
        } catch (error) {
        console.error('Erro ao fazer login:', error);
        alert('Usuário ou senha inválidos.');
        }
    };

    const handleCadastroSucess = async(e) => {
      setCadastro(false);
    }

    if(cadastro){
      return <Cadastro onCadastroSucess={handleCadastroSucess} />;
    }

    return(
        <main className="Login-App">
            <header className="Login-Header">
                <h1>Login</h1>
            </header>
            <form onSubmit={handleLogin} class="login-container">
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
                <section class="login-buttons-container">
                    <button className="login-button" 
                        onClick={(e) => { e.preventDefault(); setCadastro(true);}}
                        type="button">
                        Cadastro
                    </button>
                    <button className="login-button" type="submit">
                        Login
                    </button>
                </section>
            </form>
        </main>
    )
}

export default Login;