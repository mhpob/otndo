HTMLWidgets.widget({

  name: 'receiver_map',

  type: 'output',

  factory: function (el, width, height) {

    let map = null;

    function add_data(map, x, geojson) {
      console.log("--> [add_data] Attempting to add GeoJSON source & layer");
      
      if (!map.getSource('sf-data')) {
        console.log("--> [add_data] Adding source 'sf-data'");
        map.addSource('sf-data', { type: 'geojson', data: geojson });
      } else {
        console.log("--> [add_data] Source 'sf-data' already exists");
      }

      if (!map.getLayer('sf-point')) {
        console.log("--> [add_data] Adding layer 'sf-point'");
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
      } else {
        console.log("--> [add_data] Layer 'sf-point' already exists");
      }
    }

    return {

      renderValue: function (x) {
        console.log("1. [renderValue] Starting widget execution with payload x:", x);

        const maplibregl = window.maplibregl;

        if (!maplibregl) {
          console.error("❌ CRITICAL ERROR: window.maplibregl is undefined! Check htmlwidgets YAML dependency paths.");
          return;
        }

        console.log("2. [renderValue] Found window.maplibregl. Version:", maplibregl.version);

        // Explicitly set worker settings before map instantiation
        console.log("3. [renderValue] Current workerCount before override:", maplibregl.workerCount);
        maplibregl.workerCount = 0;
        maplibregl.workerUrl = '';
        console.log("4. [renderValue] Applied worker overrides: workerCount =", maplibregl.workerCount, "| workerUrl =", maplibregl.workerUrl);

        let geojson;
        try {
          geojson = typeof x.geojson === 'string' ? JSON.parse(x.geojson) : x.geojson;
          console.log("5. [renderValue] GeoJSON parsed successfully with", geojson.features ? geojson.features.length : 0, "features");
        } catch (err) {
          console.error("❌ ERROR: Failed to parse GeoJSON:", err);
          return;
        }

        if (!map) {
          console.log("6. [renderValue] Initializing new maplibregl.Map with style:", x.init_style);

          try {
            map = new maplibregl.Map({
              container: el.id,
              style: x.init_style,
              center: x.center
            });
            console.log("7. [renderValue] Map object instantiated successfully");
          } catch (err) {
            console.error("❌ CRITICAL ERROR: Failed to create map instance:", err);
            return;
          }

          // Error handling for map style loading / worker decoding failures
          map.on('error', function (e) {
            console.error("❌ [MAP ERROR EVENT] MapLibre caught an internal error:", e.error || e);
          });

          const popup = new maplibregl.Popup({
            closeButton: false,
            closeOnClick: false
          });

          map.on('mouseenter', 'sf-point', function (e) {
            map.getCanvas().style.cursor = 'pointer';
            const coordinates = e.features[0].geometry.coordinates.slice();
            const props = e.features[0].properties;

            const content = `
                <div style="font-family: system-ui, sans-serif; font-size: 12px; padding: 2px;">
                  <div><strong>Station:</strong> ${props.station ?? 'N/A'}</div>
                  <div><strong>Detections:</strong> ${props.Detections ?? 'N/A'}</div>
                  <div><strong>Individuals:</strong> ${props.Individuals ?? 'N/A'}</div>
                </div>
              `;

            while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
              coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
            }

            popup
              .setLngLat(coordinates)
              .setHTML(content)
              .addTo(map);
          });

          map.on('mouseleave', 'sf-point', function () {
            map.getCanvas().style.cursor = '';
            popup.remove();
          });

          map.on('load', function () {
            console.log("8. [MAP LOAD] Map initial style loaded. Calling add_data and fitting bounds.");
            add_data(map, x, geojson);

            if (x.bbox) {
              map.fitBounds([
                [x.bbox[0], x.bbox[1]],
                [x.bbox[2], x.bbox[3]]
              ], { padding: 40, maxZoom: 15 });
            }
          });

          if (x.styles && Object.keys(x.styles).length > 1) {
            console.log("9. [renderValue] Style switcher initialized with styles:", Object.keys(x.styles));
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
              option.value = typeof url === 'object' ? JSON.stringify(url) : url;
              option.textContent = name;
              select.appendChild(option);
            }

            select.addEventListener('change', function (e) {
              let selectedStyle = e.target.value;
              console.log("--> [Style Switcher] Changing style to:", selectedStyle);

              try {
                selectedStyle = JSON.parse(selectedStyle);
              } catch (err) {
                // If it's not JSON, treat as a string URL
              }

              map.setStyle(selectedStyle);

              map.once('style.load', function () {
                console.log("--> [Style Switcher] New style finished loading. Re-adding layer data.");
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