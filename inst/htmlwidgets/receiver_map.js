HTMLWidgets.widget({

  name: 'receiver_map',

  type: 'output',

  factory: function (el, width, height) {

    let map = null;

    L.TerrariumLayer = L.TileLayer.extend({
      createTile: function (coords, done) {
        const tile = document.createElement('canvas');
        const tileSize = this.getTileSize();
        tile.width = tileSize.x;
        tile.height = tileSize.y;
        const ctx = tile.getContext('2d');

        const img = new Image();
        img.crossOrigin = 'Anonymous'; // Required for canvas pixel access
        img.src = this.getTileUrl(coords); // Uses native TileLayer URL generation & wrapping

        img.onload = function () {
          ctx.drawImage(img, 0, 0, tileSize.x, tileSize.y);
          const imgData = ctx.getImageData(0, 0, tileSize.x, tileSize.y);
          const data = imgData.data;

          for (let i = 0; i < data.length; i += 4) {
            const r0 = data[i];
            const g0 = data[i + 1];
            const b0 = data[i + 2];

            // Terrarium DEM elevation formula (meters)
            const elev = (r0 * 256 + g0 + b0 / 256) - 32768;

            if (elev >= 0) {
              // Land
              data[i] = 242;
              data[i + 1] = 240;
              data[i + 2] = 235;
            } else {
              // Water: Depth in positive meters
              const depth = -elev;

              let r, g, b;

              if (depth <= 10) {
                // Zone 1: 0m to 10m (Shoals / Estuaries) -> Intense Vibrant Blue to Sky Blue
                const norm = depth / 10;
                r = Math.round(20 + norm * (80 - 20));
                g = Math.round(110 + norm * (175 - 110));
                b = Math.round(200 + norm * (235 - 200));

              } else if (depth <= 50) {
                // Zone 2: 10m to 50m (Inner Shelf) -> Sky Blue to Soft Light Blue
                const norm = (depth - 10) / 40;
                r = Math.round(80 + norm * (165 - 80));
                g = Math.round(175 + norm * (215 - 175));
                b = Math.round(235 + norm * (245 - 235));

              } else if (depth <= 100) {
                // Zone 3: 50m to 100m (Outer Shelf) -> Soft Light Blue to Pale Ice Blue
                const norm = (depth - 50) / 50;
                r = Math.round(165 + norm * (225 - 165));
                g = Math.round(215 + norm * (242 - 215));
                b = Math.round(245 + norm * (255 - 245));

              } else {
                // Zone 4: > 100m (Offshore / Deep Basin)
                r = 225;
                g = 242;
                b = 255;
              }

              data[i] = r;
              data[i + 1] = g;
              data[i + 2] = b;
            }
          }

          ctx.putImageData(imgData, 0, 0);
          done(null, tile);
        };

        img.onerror = function (err) {
          done(err, tile);
        };

        return tile;
      }
    });

    L.terrariumLayer = function (url, options) {
      return new L.TerrariumLayer(url, options);
    };

    // Layer Factory: Routes URLs to Terrarium, WMS, or standard XYZ
    function createTileLayer(url) {
      const upperUrl = url.toUpperCase();

      // Open Waters Terrarium DEM Bathymetry
      if (upperUrl.includes('OPENWATERS')) {
        return L.terrariumLayer(url, {
          minZoom: 0,
          maxZoom: 18,
          attribution: '&copy; <a href="https://openwaters.io">Open Waters</a> Bathymetry'
        });
      }

      // 2. Esri Tile Services
      if (upperUrl.includes('ARCGISONLINE')) {
        let esriAttribution = 'Tiles &copy; Esri';

        if (upperUrl.includes('GRAY_BASE')) {
          esriAttribution = 'Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ, TomTom';
        } else if (upperUrl.includes('WORLD_IMAGERY')) {
          esriAttribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';
        } else if (upperUrl.includes('WORLD_STREET_MAP')) {
          esriAttribution = 'Tiles &copy; Esri &mdash; Source: Esri, DeLorme, NAVTEQ, USGS, Intermap, iPC, NRCAN, Esri Japan, METI, Esri China (Hong Kong), Esri (Thailand), TomTom, 2012';
        }

        return L.tileLayer(url, {
          minZoom: 0,
          maxZoom: 19,
          maxNativeZoom: 18,
          attribution: esriAttribution
        });
      }

      // 3. Fallback XYZ Provider
      return L.tileLayer(url, {
        minZoom: 0,
        maxZoom: 19,
        maxNativeZoom: 18,
        attribution: '&copy; Basemap Provider'
      });
    }

    // Interpolate radius based on detections
    function getRadius(val, minVal, maxVal) {
      if (maxVal === minVal || isNaN(val)) return 6;
      const norm = Math.max(0, Math.min(1, (val - minVal) / (maxVal - minVal)));
      return 4 + norm * 11;
    }

    // Interpolate color based on individuals
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

        let geojson;
        try {
          geojson = typeof x.geojson === 'string' ? JSON.parse(x.geojson) : x.geojson;
        } catch (err) {
          console.error("❌ Failed to parse GeoJSON:", err);
          return;
        }

        if (!map) {
          map = L.map(el.id, {
            zoomControl: true,
            attributionControl: true
          });

          // Add basemap layers dynamically
          const baseMaps = {};
          if (x.backgrounds && Object.keys(x.backgrounds).length > 0) {
            let isFirst = true;
            for (const [name, url] of Object.entries(x.backgrounds)) {
              const layer = createTileLayer(url);
              baseMaps[name] = layer;
              if (isFirst) {
                layer.addTo(map);
                isFirst = false;
              }
            }

            if (Object.keys(baseMaps).length > 1) {
              L.control.layers(baseMaps, null, { position: 'topright' }).addTo(map);
            }
          }

          // Add GeoJSON receiver points
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