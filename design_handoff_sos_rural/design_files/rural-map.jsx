// RuralMap — Leaflet + OpenStreetMap, muted for a light premium UI.
// window.RuralMap
const { useRef, useEffect } = React;

function whenL(cb) {
  if (window.L) return cb();
  const t = setInterval(() => { if (window.L) { clearInterval(t); cb(); } }, 60);
  setTimeout(() => clearInterval(t), 15000);
}

function RuralMap({
  center = [-32.9251, -60.9805],
  zoom = 13,
  route = null,          // [[lat,lng],...]
  routeColor = '#2F4FD8',
  pin = true,
  entrance = null,       // [lat,lng]
  draw = false,
  drive = false,
  interactive = false,
  api = null,            // object to attach {undo, clear}
  onCount = null,
}) {
  const host = useRef(null);
  const mapRef = useRef(null);
  const ptsRef = useRef([]);
  const lineRef = useRef(null);
  const dotsRef = useRef([]);

  useEffect(() => {
    let dead = false;
    whenL(() => {
      if (dead || !host.current || mapRef.current) return;
      const map = L.map(host.current, {
        zoomControl: false, attributionControl: true,
        dragging: interactive, scrollWheelZoom: false, doubleClickZoom: interactive,
        touchZoom: interactive, boxZoom: false, keyboard: false, tap: false,
      });
      map.setView(center, zoom);
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors', maxZoom: 18,
      }).addTo(map);
      const tp = map.getPane('tilePane');
      if (tp) tp.style.filter = 'saturate(0.28) contrast(0.9) brightness(1.07)';

      if (route && route.length > 1) {
        L.polyline(route, { color: '#fff', weight: 9, opacity: 0.9, lineCap: 'round' }).addTo(map);
        L.polyline(route, { color: routeColor, weight: 4.5, opacity: 1, lineCap: 'round' }).addTo(map);
      }
      if (entrance) {
        L.circleMarker(entrance, { radius: 6, color: '#fff', weight: 2.5, fillColor: '#1E9E62', fillOpacity: 1 }).addTo(map);
      }
      if (pin) {
        L.circleMarker(center, { radius: 11, color: 'rgba(23,24,27,0.10)', weight: 10, fillColor: '#17181B', fillOpacity: 1 }).addTo(map);
      }
      if (drive && route && route.length > 1) {
        L.circleMarker(route[route.length - 1], { radius: 8, color: '#fff', weight: 3, fillColor: routeColor, fillOpacity: 1 }).addTo(map);
      }

      const redraw = () => {
        if (lineRef.current) { map.removeLayer(lineRef.current); lineRef.current = null; }
        dotsRef.current.forEach(d => map.removeLayer(d));
        dotsRef.current = [];
        const pts = ptsRef.current;
        if (pts.length > 1) {
          lineRef.current = L.polyline(pts, { color: routeColor, weight: 4.5, opacity: 1, lineCap: 'round' }).addTo(map);
        }
        pts.forEach((p, i) => {
          dotsRef.current.push(L.circleMarker(p, {
            radius: i === 0 ? 6 : 4.5, color: '#fff', weight: 2,
            fillColor: i === 0 ? '#1E9E62' : routeColor, fillOpacity: 1,
          }).addTo(map));
        });
        if (onCount) onCount(pts.length);
      };

      if (draw) {
        map.on('click', e => { ptsRef.current = ptsRef.current.concat([[e.latlng.lat, e.latlng.lng]]); redraw(); });
        if (api) {
          api.undo = () => { ptsRef.current = ptsRef.current.slice(0, -1); redraw(); };
          api.clear = () => { ptsRef.current = []; redraw(); };
        }
      }

      mapRef.current = map;
      setTimeout(() => map.invalidateSize(), 150);
      setTimeout(() => map.invalidateSize(), 600);
    });
    return () => {
      dead = true;
      if (mapRef.current) { mapRef.current.remove(); mapRef.current = null; }
    };
  }, []);

  return React.createElement('div', {
    ref: host,
    style: { position: 'absolute', inset: 0, background: '#E9E9E5' },
  });
}

window.RuralMap = RuralMap;
