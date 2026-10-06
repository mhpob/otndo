FROM node:current-alpine

WORKDIR /build

# Install MapLibre GL JS v6 and esbuild
RUN npm install maplibre-gl esbuild

# Define output volume directory
VOLUME /out

# Bundle maplibre-gl.mjs into an IIFE script and copy CSS to /out
CMD ["sh", "-c", "\
  npx esbuild node_modules/maplibre-gl/dist/maplibre-gl.mjs \
    --bundle \
    --minify \
    --format=iife \
    --global-name=maplibregl \
    --outfile=/out/maplibre-gl.js && \
  cp node_modules/maplibre-gl/dist/maplibre-gl.css /out/maplibre-gl.css \
"]

# docker build -t bundle_maplibre -f inst/htmlwidgets/Dockerfile .
# docker run --rm -v "$(pwd)/inst/htmlwidgets/lib/maplibre:/out" bundle_maplibre 
