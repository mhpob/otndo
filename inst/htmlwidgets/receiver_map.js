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

    return {

      renderValue: function (x) {

        if (!map) {
          map = L.map(el.id, {
            zoomControl: true,
            attributionControl: true
          });

          // Add basemap
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

          /// Add data, iterating over station
          L.layerGroup(
            x.station.map((stationName, i) =>
              L.circleMarker([x.latitude[i], x.longitude[i]], {
                radius: x.ind_radius[i],
                fillColor: x.det_colors[i],
                color: '#ffffff',
                weight: 1.5,
                opacity: 1,
                fillOpacity: 0.85
              }).bindTooltip(x.tooltip[i], { sticky: true })
            )
          ).addTo(map);

          const legend = L.control({ position: 'bottomright' });

          legend.onAdd = function () {
            const div = L.DomUtil.create('div', 'info legend');
            div.style.cssText = 'background: white; padding: 10px; border-radius: 5px; box-shadow: 0 0 15px rgba(0,0,0,0.2); font-family: system-ui, sans-serif; font-size: 12px; line-height: 1.4;';
            div.innerHTML = x.legend;
            return div;
          };

          legend.addTo(map);

          // Set viewport bounds
          if (x.bbox?.length === 4) {
            map.fitBounds([[x.bbox[0], x.bbox[1]], [x.bbox[2], x.bbox[3]]], 
              { padding: [20, 20] });
          } else if (x.center) {
            map.setView([x.center[0], x.center[1]], 10);
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