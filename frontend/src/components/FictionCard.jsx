import { authAPI } from '../services/api';

export default function FictionCard({ fiction, onEdit, onDelete }) {
  const currentUser = authAPI.getUser();
  const isOwner = currentUser && fiction.created_by === currentUser._id;

  return (
    <div className="card">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <h3>{fiction.title}</h3>
        {isOwner && (
          <span style={{ 
            background: '#2563eb', 
            color: 'white', 
            padding: '0.25rem 0.5rem', 
            borderRadius: '4px', 
            fontSize: '0.75rem',
            fontWeight: '500'
          }}>
            Your Story
          </span>
        )}
      </div>
      <p><strong>Author:</strong> {fiction.author}</p>
      <p>
        <span className="genre-pill">{fiction.genre}</span>
      </p>
      <p><strong>Description:</strong> {fiction.description}</p>
      
      <div className="card-content">
        <strong>Story:</strong>
        <div style={{ marginTop: '0.5rem' }}>
          {fiction.content.length > 200 
            ? `${fiction.content.substring(0, 200)}...` 
            : fiction.content
          }
        </div>
      </div>

      {isOwner && (
        <div className="card-actions">
          <button 
            className="btn btn-primary"
            onClick={() => onEdit(fiction)}
          >
            Edit
          </button>
          <button 
            className="btn btn-danger"
            onClick={() => onDelete(fiction._id)}
          >
            Delete
          </button>
        </div>
      )}
    </div>
  );
}

