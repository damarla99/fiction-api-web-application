import { useState, useEffect } from 'react';
import { fictionsAPI } from '../services/api';
import FictionForm from './FictionForm';
import FictionCard from './FictionCard';

export default function Fictions() {
  const [fictions, setFictions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [editingFiction, setEditingFiction] = useState(null);

  useEffect(() => {
    loadFictions();
  }, []);

  const loadFictions = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await fictionsAPI.getAll();
      setFictions(data);
    } catch (err) {
      setError(err.message || 'Failed to load fictions');
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (fictionData) => {
    try {
      await fictionsAPI.create(fictionData);
      await loadFictions();
      return true;
    } catch (err) {
      throw new Error(err.message || 'Failed to create fiction');
    }
  };

  const handleUpdate = async (id, fictionData) => {
    try {
      await fictionsAPI.update(id, fictionData);
      await loadFictions();
      setEditingFiction(null);
      return true;
    } catch (err) {
      throw new Error(err.message || 'Failed to update fiction');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this fiction?')) {
      return;
    }

    try {
      await fictionsAPI.delete(id);
      await loadFictions();
    } catch (err) {
      alert(err.message || 'Failed to delete fiction');
    }
  };

  const handleEdit = (fiction) => {
    setEditingFiction(fiction);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleCancelEdit = () => {
    setEditingFiction(null);
  };

  if (loading) {
    return <div className="loading">Loading fictions...</div>;
  }

  return (
    <div className="container">
      <FictionForm 
        onSubmit={editingFiction ? handleUpdate : handleCreate}
        editingFiction={editingFiction}
        onCancel={handleCancelEdit}
      />

      {error && <div className="error">{error}</div>}

      {fictions.length === 0 ? (
        <div className="empty-state">
          <h3>No Fictions Yet</h3>
          <p>Create your first fiction using the form above!</p>
        </div>
      ) : (
        <div>
          <h2 style={{ marginBottom: '1.5rem', color: '#333' }}>
            All Fictions ({fictions.length})
          </h2>
          {fictions.map((fiction) => (
            <FictionCard
              key={fiction._id}
              fiction={fiction}
              onEdit={handleEdit}
              onDelete={handleDelete}
            />
          ))}
        </div>
      )}
    </div>
  );
}

