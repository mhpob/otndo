HTMLWidgets.widget({

  name: 'receiver_map',

  type: 'output',

  factory: function (el, width, height) {

    let map = null;

    function add_data(map, x, geojson) {
      map.addSource('sf-data', { type: 'geojson', data: geojson });
      map.addLayer({
        id: 'sf-point',
        type: 'circle',
        source: 'sf-data',
        filter: ['==', '$type', 'Point'],
        paint: {
          'circle-radius': [
            "interpolate",
            ["linear"],
            ["get", "Detections"],
            x.min_det, 4,
            x.max_det, 15
          ],
          'circle-color': [
            "interpolate",
            ["linear"],
            ["get", "Individuals"],
            x.min_indiv, "#0d0887",
            (x.min_indiv + x.max_indiv) / 2, "#cc4678",
            x.max_indiv, "#f0f921"
          ]
        }
      });
    }


    return {

      renderValue: async function (x) {
        if (!document.querySelector('link[href*="maplibre-gl.css"]')) {
          const link = document.createElement('link');
          link.rel = 'stylesheet';
          link.href = 'https://unpkg.com/maplibre-gl@6.12.0/dist/maplibre-gl.css';
          document.head.appendChild(link);
        }

        if (!window.maplibregl) {
          // const maplibre = await import('../maplibre-gl-6.12.0/maplibre-gl.mjs');
          const maplibre = await import('https://unpkg.com/maplibre-gl@6.12.0/dist/maplibre-gl.mjs');
          window.maplibregl = maplibre.default || maplibre;
        }

        const maplibregl = window.maplibregl;
        const geojson = JSON.parse(x.geojson);

        if (!map) {
          map = new maplibregl.Map({
            container: el.id,
            style: x.init_style,
            center: x.center
          });

          const popup = new maplibregl.Popup({
            closeButton: false,
            closeOnClick: false
          });






          map.on('mouseenter', 'sf-point', function (e) {
            // Change mouse cursor to pointer
            map.getCanvas().style.cursor = 'pointer';

            const coordinates = e.features[0].geometry.coordinates.slice();
            const props = e.features[0].properties;

            // Build clean HTML content with fallbacks for missing properties
            const content = `
                <div style="font-family: system-ui, sans-serif; font-size: 12px; padding: 2px;">
                  <div><strong>Station:</strong> ${props.station ?? 'N/A'}</div>
                  <div><strong>Detections:</strong> ${props.Detections ?? 'N/A'}</div>
                  <div><strong>Individuals:</strong> ${props.Individuals ?? 'N/A'}</div>
                </div>
              `;

            // Handle map projection wrapping across -180/180 longitude boundaries
            while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
              coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
            }

            // Position and attach popup to map
            popup
              .setLngLat(coordinates)
              .setHTML(content)
              .addTo(map);
          });

          // Hide popup and reset cursor when moving off a point
          map.on('mouseleave', 'sf-point', function () {
            map.getCanvas().style.cursor = '';
            popup.remove();
          });

          map.on('load', function () {
            add_data(map, x, geojson);

            map.fitBounds([
              [x.bbox[0], x.bbox[1]],
              [x.bbox[2], x.bbox[3]]
            ], { padding: 40, maxZoom: 15 });
          });

          if (x.styles && Object.keys(x.styles).length > 1) {
            const pickerDiv = document.createElement('div');
            pickerDiv.className = 'maplibre-style-picker';
            pickerDiv.style.cssText = `
              position: absolute;
              top: 10px;
              right: 10px;
              z-index: 10;
              background: #ffffff;
              padding: 6px 10px;
              border-radius: 4px;
              box-shadow: 0 1px 4px rgba(0,0,0,0.3);
              font-family: system-ui, -apple-system, sans-serif;
              font-size: 12px;
            `;

            const select = document.createElement('select');
            select.style.cssText = 'border: none; background: transparent; outline: none; cursor: pointer; font-weight: 500;';

            for (const [name, url] of Object.entries(x.styles)) {
              const option = document.createElement('option');
              option.value = url;
              option.textContent = name;
              select.appendChild(option);
            }

            select.addEventListener('change', function (e) {
              const selectedStyle = e.target.value;
              map.setStyle(selectedStyle);

              // Re-add sources and layers once new style finishes loading
              map.once('style.load', function () {
                add_data(map, x, geojson);
              });
            });

            pickerDiv.appendChild(select);
            el.appendChild(pickerDiv);
          }
        }
      },

      resize: function (width, height) {
        if (map) map.resize();
      }
    };
  }
});