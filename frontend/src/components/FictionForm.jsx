import { useState, useEffect } from 'react';

const GENRES = [
  'fantasy', 'sci-fi', 'mystery', 'romance', 'thriller', 
  'horror', 'adventure', 'drama', 'comedy', 'other'
];

export default function FictionForm({ onSubmit, editingFiction, onCancel }) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState({
    title: '',
    author: '',
    genre: 'fantasy',
    description: '',
    content: '',
  });

  useEffect(() => {
    if (editingFiction) {
      setFormData({
        title: editingFiction.title,
        author: editingFiction.author,
        genre: editingFiction.genre,
        description: editingFiction.description,
        content: editingFiction.content,
      });
    } else {
      resetForm();
    }
  }, [editingFiction]);

  const resetForm = () => {
    setFormData({
      title: '',
      author: '',
      genre: 'fantasy',
      description: '',
      content: '',
    });
    setError('');
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (editingFiction) {
        await onSubmit(editingFiction._id, formData);
      } else {
        await onSubmit(formData);
      }
      resetForm();
    } catch (err) {
      setError(err.message || 'Failed to save fiction');
    } finally {
      setLoading(false);
    }
  };

  const handleCancelClick = () => {
    resetForm();
    if (onCancel) onCancel();
  };

  return (
    <div className="fiction-form">
      <h3>{editingFiction ? 'Edit Fiction' : 'Create New Fiction'}</h3>
      
      {error && <div className="error">{error}</div>}
      
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Title *</label>
          <input
            type="text"
            name="title"
            value={formData.title}
            onChange={handleChange}
            required
            maxLength={200}
            placeholder="Enter fiction title"
          />
        </div>

        <div className="form-group">
          <label>Author *</label>
          <input
            type="text"
            name="author"
            value={formData.author}
            onChange={handleChange}
            required
            maxLength={100}
            placeholder="Enter author name"
          />
        </div>

        <div className="form-group">
          <label>Genre *</label>
          <select
            name="genre"
            value={formData.genre}
            onChange={handleChange}
            required
          >
            {GENRES.map((genre) => (
              <option key={genre} value={genre}>
                {genre.charAt(0).toUpperCase() + genre.slice(1)}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label>Description *</label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            required
            maxLength={500}
            placeholder="Enter a brief description (max 500 characters)"
            rows={3}
          />
        </div>

        <div className="form-group">
          <label>Content *</label>
          <textarea
            name="content"
            value={formData.content}
            onChange={handleChange}
            required
            placeholder="Enter the full story content"
            rows={6}
          />
        </div>

        <div>
          <button 
            type="submit" 
            className="btn btn-primary"
            disabled={loading}
          >
            {loading ? 'Saving...' : (editingFiction ? 'Update Fiction' : 'Create Fiction')}
          </button>
          
          {editingFiction && (
            <button 
              type="button" 
              className="btn btn-secondary"
              onClick={handleCancelClick}
            >
              Cancel
            </button>
          )}
        </div>
      </form>
    </div>
  );
}

