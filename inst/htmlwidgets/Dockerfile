FROM node:current-alpine

WORKDIR /build

# Install Leaflet
RUN npm install leaflet

# Define output volume directory
VOLUME /out

# Copy pre-built Leaflet distribution files and icon assets to /out
CMD ["sh", "-c", "\
  cp node_modules/leaflet/dist/leaflet.js /out/leaflet.js && \
  cp node_modules/leaflet/dist/leaflet.css /out/leaflet.css && \
  mkdir -p /out/images && \
  cp node_modules/leaflet/dist/images/* /out/images/ \
"]

# docker build -t bundle_leaflet -f inst/htmlwidgets/Dockerfile .
# docker run --rm -v "$(pwd)/inst/htmlwidgets/lib/leaflet:/out" bundle_leaflet