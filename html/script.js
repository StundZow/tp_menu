let currentPlayers = [];

const app = document.getElementById('app');
const playerList = document.getElementById('playerList');
const searchInput = document.getElementById('search');
const closeBtn = document.getElementById('closeBtn');

function postNui(name, data) {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data || {})
  });
}

function renderPlayers(players) {
  playerList.innerHTML = '';

  const filter = searchInput.value.trim().toLowerCase();
  const filtered = players.filter(p => p.name.toLowerCase().includes(filter));

  if (filtered.length === 0) {
    const empty = document.createElement('p');
    empty.className = 'empty-state';
    empty.textContent = 'Aucun joueur trouvé.';
    playerList.appendChild(empty);
    return;
  }

  filtered.forEach(p => {
    const row = document.createElement('div');
    row.className = 'player-row';

    row.innerHTML = `
      <div class="player-info">
        <button class="blip-toggle ${p.blipHidden ? 'off' : ''}" title="${blipTitle(p)}">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="9"></circle>
            <polygon points="15,9 13,13 9,15 11,11" fill="currentColor" stroke="none"></polygon>
            <circle cx="12" cy="12" r="1" fill="currentColor" stroke="none"></circle>
          </svg>
        </button>
        <span class="player-name">${escapeHtml(p.name)}</span>
        <span class="player-id">#${p.id}</span>
      </div>
      <div class="player-actions">
        <button class="action-btn goto">Aller vers</button>
        <button class="action-btn bring">Faire venir</button>
      </div>
    `;

    // L'état est géré par le serveur (global) : le menu se met à jour via updatePlayers
    row.querySelector('.blip-toggle').addEventListener('click', () => {
      postNui('toggleBlip', { id: p.id });
    });

    row.querySelector('.goto').addEventListener('click', () => {
      postNui('tpToPlayer', { id: p.id });
    });

    row.querySelector('.bring').addEventListener('click', () => {
      postNui('tpPlayerToMe', { id: p.id });
    });

    playerList.appendChild(row);
  });
}

function blipTitle(p) {
  const scope = p.sync ? 'pour tout le monde' : 'pour vous';
  return p.blipHidden
    ? `Blip masqué ${scope} - cliquer pour réafficher`
    : `Masquer le blip de ce joueur ${scope}`;
}

function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

searchInput.addEventListener('input', () => renderPlayers(currentPlayers));

closeBtn.addEventListener('click', () => postNui('close'));

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    postNui('close');
  }
});

window.addEventListener('message', (event) => {
  const data = event.data;

  if (data.action === 'open') {
    currentPlayers = data.players || [];
    app.classList.remove('hidden');
    searchInput.value = '';
    renderPlayers(currentPlayers);
    searchInput.focus();
  } else if (data.action === 'close') {
    app.classList.add('hidden');
  } else if (data.action === 'updatePlayers') {
    currentPlayers = data.players || [];
    if (!app.classList.contains('hidden')) {
      renderPlayers(currentPlayers);
    }
  }
});
