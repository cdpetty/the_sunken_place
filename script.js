// Render the music feed from JSON
document.addEventListener('DOMContentLoaded', async () => {
  const feed = document.getElementById('feed');
  if (!feed) return;

  try {
    const response = await fetch('data.json');
    const musicFeed = await response.json();

    musicFeed.forEach(item => {
      const card = document.createElement('article');
      card.className = 'music-card';

      card.innerHTML = `
        <div class="album-art">
          <img src="${item.albumArt}" alt="${item.title} by ${item.artist}" loading="lazy" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22120%22 height=%22120%22%3E%3Crect fill=%22%231a1a1a%22 width=%22120%22 height=%22120%22/%3E%3Ctext fill=%22%233a3a3a%22 x=%2260%22 y=%2265%22 text-anchor=%22middle%22 font-family=%22monospace%22%3E?%3C/text%3E%3C/svg%3E'">
        </div>
        <div class="music-info">
          <span class="artist">${item.artist}</span>
          <span class="title">${item.title}</span>
          <div class="meta">
            <span class="type">${item.type}</span>
            <span class="year">${item.year}</span>
          </div>
        </div>
      `;

      feed.appendChild(card);
    });
  } catch (error) {
    feed.innerHTML = '<p style="color: #666;">Failed to load music feed.</p>';
  }
});
