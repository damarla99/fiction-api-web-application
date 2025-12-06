import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { authAPI } from './services/api';
import Login from './components/Login';
import Fictions from './components/Fictions';
import Navbar from './components/Navbar';
import PrivateRoute from './components/PrivateRoute';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/" 
          element={
            authAPI.isAuthenticated() 
              ? <Navigate to="/fictions" /> 
              : <Login />
          } 
        />
        <Route 
          path="/fictions" 
          element={
            <PrivateRoute>
              <Navbar />
              <Fictions />
            </PrivateRoute>
          } 
        />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

