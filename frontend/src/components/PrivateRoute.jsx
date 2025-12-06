import { Navigate } from 'react-router-dom';
import { authAPI } from '../services/api';

export default function PrivateRoute({ children }) {
  return authAPI.isAuthenticated() ? children : <Navigate to="/" />;
}

