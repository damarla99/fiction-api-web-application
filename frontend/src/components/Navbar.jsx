import { useNavigate } from 'react-router-dom';
import { authAPI } from '../services/api';

export default function Navbar() {
  const navigate = useNavigate();
  const user = authAPI.getUser();

  const handleLogout = () => {
    authAPI.logout();
    navigate('/');
  };

  return (
    <nav className="navbar">
      <h1>📚 Fictions App</h1>
      <div className="user-info">
        <span>Welcome, {user?.username || user?.email}!</span>
        <button onClick={handleLogout}>Logout</button>
      </div>
    </nav>
  );
}

