HTMLWidgets.widget({

  name: 'receiver_map',

  type: 'output',

  factory: function (el, width, height) {

    let map = null;

    // interpolate radius based on detections
    function getRadius(val, minVal, maxVal) {
      if (maxVal === minVal || isNaN(val)) return 6;
      const norm = Math.max(0, Math.min(1, (val - minVal) / (maxVal - minVal)));
      return 4 + norm * 11;
    }

    // interpolate color based on individuals
    function getColor(val, minVal, maxVal) {
      if (maxVal === minVal || isNaN(val)) return "#cc4678";
      const norm = Math.max(0, Math.min(1, (val - minVal) / (maxVal - minVal)));
      
      let c1, c2, factor;
      if (norm < 0.5) {
        c1 = [13, 8, 135];    // #0d0887
        c2 = [204, 70, 120];  // #cc4678
        factor = norm * 2;
      } else {
        c1 = [204, 70, 120];  // #cc4678
        c2 = [240, 249, 33];  // #f0f921
        factor = (norm - 0.5) * 2;
      }
      const r = Math.round(c1[0] + factor * (c2[0] - c1[0]));
      const g = Math.round(c1[1] + factor * (c2[1] - c1[1]));
      const b = Math.round(c1[2] + factor * (c2[2] - c1[2]));
      return `rgb(${r},${g},${b})`;
    }

    return {

      renderValue: function (x) {

        if (!window.L) {
          console.error("❌ Leaflet JS library (window.L) is missing. Check htmlwidgets YAML configuration.");
          return;
        }

        let geojson;
        try {
          geojson = typeof x.geojson === 'string' ? JSON.parse(x.geojson) : x.geojson;
        } catch (err) {
          console.error("❌ Failed to parse GeoJSON:", err);
          return;
        }

        // Initialize map instance if it doesn't exist
        if (!map) {
          map = L.map(el.id, {
            zoomControl: true,
            attributionControl: true
          });

          // Add basemap tile layers
          const baseMaps = {};
          if (x.styles && Object.keys(x.styles).length > 0) {
            let isFirst = true;
            for (const [name, url] of Object.entries(x.styles)) {
              const layer = L.tileLayer(url, {
                maxZoom: 19,
                subdomains: 'abcd',
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>'
              });
              baseMaps[name] = layer;
              if (isFirst) {
                layer.addTo(map);
                isFirst = false;
              }
            }

            if (Object.keys(baseMaps).length > 1) {
              L.control.layers(baseMaps, null, { position: 'topright' }).addTo(map);
            }
          } else {
            L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
              maxZoom: 19,
              attribution: '&copy; OpenStreetMap &copy; CARTO'
            }).addTo(map);
          }

          // Add GeoJSON point layer with dynamic circle sizing & coloring
          L.geoJSON(geojson, {
            pointToLayer: function (feature, latlng) {
              const props = feature.properties || {};
              const det = props.Detections;
              const indiv = props.Individuals;

              const marker = L.circleMarker(latlng, {
                radius: getRadius(det, x.min_det, x.max_det),
                fillColor: getColor(indiv, x.min_indiv, x.max_indiv),
                color: '#ffffff',
                weight: 1.5,
                opacity: 1,
                fillOpacity: 0.85
              });

              const tooltipContent = `
                <div style="font-family: system-ui, sans-serif; font-size: 12px; padding: 2px;">
                  <div><strong>Station:</strong> ${props.station ?? 'N/A'}</div>
                  <div><strong>Detections:</strong> ${props.Detections ?? 'N/A'}</div>
                  <div><strong>Individuals:</strong> ${props.Individuals ?? 'N/A'}</div>
                </div>
              `;

              marker.bindTooltip(tooltipContent, { sticky: true });
              return marker;
            }
          }).addTo(map);

          // Set viewport bounds
          if (x.bbox && x.bbox.length === 4) {
            // Leaflet bbox format: [[ymin, xmin], [ymax, xmax]]
            map.fitBounds([
              [x.bbox[1], x.bbox[0]],
              [x.bbox[3], x.bbox[2]]
            ], { padding: [20, 20] });
          } else if (x.center) {
            map.setView([x.center[1], x.center[0]], 10);
          }
        }
      },

      resize: function (width, height) {
        if (map) {
          map.invalidateSize();
        }
      }
    };
  }
});