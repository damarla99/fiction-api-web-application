# Fictions Frontend

Simple React frontend for the Fictions API.

## Features

- **Login/Register** - JWT authentication
- **List Fictions** - View all fictions
- **Create Fiction** - Add new stories
- **Edit Fiction** - Update existing stories
- **Delete Fiction** - Remove stories

## Tech Stack

- React 18
- Vite (build tool)
- React Router (routing)
- Vanilla CSS (styling)

## Local Development

### Prerequisites

- Node.js 18+
- Backend API running on `http://localhost:3000`

### Run Locally

```bash
# Install dependencies
npm install

# Start dev server
npm run dev
```

Visit `http://localhost:5173`

### Build for Production

```bash
# Create production build
npm run build

# Preview production build
npm run preview
```

## Docker

### Build Image

```bash
docker build -t fictions-frontend .
```

### Run Container

```bash
docker run -p 80:80 fictions-frontend
```

## API Integration

The frontend automatically detects the environment:

- **Local**: Uses `http://localhost:3000` for API calls
- **Production**: Uses same origin (served via Ingress with path routing)

## Authentication

- JWT tokens stored in `localStorage`
- Automatic token attachment to authenticated requests
- Redirect to login if not authenticated

## Project Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── Login.jsx           # Login/Register form
│   │   ├── Fictions.jsx        # Main fictions page
│   │   ├── FictionForm.jsx     # Create/Edit form
│   │   ├── FictionCard.jsx     # Fiction display card
│   │   ├── Navbar.jsx          # Navigation bar
│   │   └── PrivateRoute.jsx    # Auth protection
│   ├── services/
│   │   └── api.js              # API client
│   ├── App.jsx                 # Main app component
│   ├── main.jsx                # Entry point
│   └── index.css               # Global styles
├── Dockerfile                  # Multi-stage build
├── nginx.conf                  # Nginx config for SPA
└── package.json
```

## Environment Variables

No environment variables needed! The app automatically detects:

- **Development**: Proxies `/api` to `http://localhost:3000`
- **Production**: Uses same origin for API calls

