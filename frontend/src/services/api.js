// API base URL - works in both local dev and production
const API_BASE_URL = window.location.hostname === 'localhost' 
  ? 'http://localhost:3000' 
  : '';

// Helper to get auth token
const getAuthToken = () => localStorage.getItem('token');

// Helper for API calls
async function apiCall(endpoint, options = {}) {
  const token = getAuthToken();
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  // Add auth token if available
  if (token && !endpoint.includes('/auth/')) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: 'Request failed' }));
    throw new Error(error.detail || `HTTP ${response.status}`);
  }

  return response.json();
}

// Auth API
export const authAPI = {
  login: async (email, password) => {
    const data = await apiCall('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    
    // Store token
    if (data.token) {
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify(data.user));
    }
    
    return data;
  },

  register: async (username, email, password) => {
    const data = await apiCall('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify({ username, email, password }),
    });
    
    // Store token
    if (data.token) {
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify(data.user));
    }
    
    return data;
  },

  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  isAuthenticated: () => {
    return !!getAuthToken();
  },

  getUser: () => {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
  },
};

// Fictions API
export const fictionsAPI = {
  getAll: () => apiCall('/api/fictions/'),
  
  getById: (id) => apiCall(`/api/fictions/${id}`),
  
  create: (fiction) => apiCall('/api/fictions/', {
    method: 'POST',
    body: JSON.stringify(fiction),
  }),
  
  update: (id, fiction) => apiCall(`/api/fictions/${id}`, {
    method: 'PUT',
    body: JSON.stringify(fiction),
  }),
  
  delete: (id) => apiCall(`/api/fictions/${id}`, {
    method: 'DELETE',
  }),
};

